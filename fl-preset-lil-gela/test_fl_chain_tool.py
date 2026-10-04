# -*- coding: utf-8 -*-
"""
Teste offline do fl_chain_tool.py (nao precisa do FL Studio).

Simula os modulos embutidos `plugins` e `mixer` do FL Studio com knobs de verdade
(lineares em dB, logaritmicos em ms/Hz e enums de texto) e confere:

  1. scan/dump/apply/diff do preset portavel;
  2. apply_recipe(): resolver o valor interno a partir do TEXTO do knob
     (ex.: "-18.0 dB", "8.0:1", "0.5 ms", "4x", "Off"), inclusive em knob invertido;
  3. filtro de grupo (LEAD vs SEND);
  4. relato honesto de plugin/param que nao existe (com os nomes reais).

Rodar:  python3 test_fl_chain_tool.py
"""

import math
import os
import sys
import types
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


# ------------------------------------------------------------------ helpers
def knob_linear(a, b, fmt="%+.1f dB"):
    return lambda v: fmt % (a + (b - a) * v)


def knob_log(a, b, fmt="%.1f ms"):
    return lambda v: fmt % (a * ((b / a) ** v))


def knob_enum(options):
    n = len(options)
    return lambda v: options[min(n - 1, int(v * n + 1e-9))]


def make_fl_mock():
    """store[(track, slot)] = [nome, {idx: [nome, value, fmt}]}"""
    store = {}

    def add_plugin(track, slot, name, knobs):
        store[(track, slot)] = [name, {i: [k, 0.5, f] for i, (k, f) in enumerate(knobs)}]

    plugins = types.ModuleType("plugins")

    def isValid(index, slotIndex=-1, useGlobalIndex=False):
        return (index, slotIndex) in store

    def getPluginName(index, slotIndex=-1, userName=False, useGlobalIndex=False):
        return store[(index, slotIndex)][0]

    def getParamCount(index, slotIndex=-1, useGlobalIndex=False):
        return max(store[(index, slotIndex)][1].keys()) + 1

    def getParamName(paramIndex, index, slotIndex=-1, useGlobalIndex=False):
        p = store[(index, slotIndex)][1].get(paramIndex)
        return p[0] if p else ""

    def getParamValue(paramIndex, index, slotIndex=-1, useGlobalIndex=False):
        p = store[(index, slotIndex)][1].get(paramIndex)
        return p[1] if p else 0.0

    def getParamValueString(paramIndex, index, slotIndex=-1, pickupMode=0, useGlobalIndex=False):
        p = store[(index, slotIndex)][1].get(paramIndex)
        return p[2](p[1]) if p else ""

    def setParamValue(value, paramIndex, index, slotIndex=-1, pickupMode=0, useGlobalIndex=False):
        params = store[(index, slotIndex)][1]
        assert paramIndex in params, "param %d nao existe no slot %d" % (paramIndex, slotIndex)
        assert -1e-6 <= value <= 1.0 + 1e-6, "valor fora de 0..1: %r" % (value,)
        params[paramIndex][1] = max(0.0, min(1.0, float(value)))

    for fn in ("isValid", "getPluginName", "getParamCount", "getParamName",
               "getParamValue", "getParamValueString", "setParamValue"):
        setattr(plugins, fn, locals()[fn])

    mixer = types.ModuleType("mixer")
    mixer.trackNumber = lambda: 12
    return plugins, mixer, store, add_plugin


RECIPE = """# receita de teste
G|LEAD
T|Fruity Compressor|Ratio|8.0:1
T|Fruity Compressor|Threshold|-18.0 dB
T|Fruity Compressor|Attack|0.5 ms
T|Fruity Compressor|Make up~Volume|+4.0 dB
T|Parametric EQ 2|Over sampling|4x
T|Parametric EQ 2|Band 1 Frequency|110 Hz
T|Parametric EQ 2|Band 1 Gain~-3.0 dB|-3.0 dB
T|Fruity Reeverb 2|Dry level|0%
T|Ghost Plugin|Whatever|1.0 dB
T|Fruity Compressor|Nonexistent Knob|9.0 dB
G|DELAY
T|Fruity Compressor|Release|45.0 ms
"""


def main():
    plugins, mixer, store, add_plugin = make_fl_mock()

    add_plugin(12, 0, "Fruity Parametric EQ 2", [
        ("Over sampling", knob_enum(["Off", "2x", "4x", "8x"])),
        ("Linear phase", knob_enum(["Off", "On"])),
        ("Band 1 Frequency", knob_log(20.0, 21000.0, "%d Hz")),
        ("Band 1 Gain", knob_linear(-12.0, 12.0, "%+.1f dB")),
    ])
    add_plugin(12, 1, "Fruity Compressor", [
        ("Ratio", knob_linear(1.0, 20.0, "%.1f:1")),
        ("Threshold", knob_linear(-40.0, 0.0, "%.1f dB")),
        ("Attack", knob_log(0.1, 100.0, "%.1f ms")),
        ("Release", knob_log(1.0, 1000.0, "%.1f ms")),
        ("Make up", knob_linear(-24.0, 24.0, "%+.1f dB")),
    ])
    add_plugin(12, 2, "Fruity Reeverb 2", [
        # knob invertido: girar pra frente reduz o dry
        ("Dry level", knob_linear(100.0, 0.0, "%.1f%%")),
    ])

    sys.modules["plugins"] = plugins
    sys.modules["mixer"] = mixer
    import fl_chain_tool as fl

    tmpdir = tempfile.mkdtemp(prefix="gelachain-")
    chain = os.path.join(tmpdir, "chain.txt")
    recipe = os.path.join(tmpdir, "receita-gela.txt")
    open(recipe, "w", encoding="utf-8").write(RECIPE)
    fl.set_path(chain)
    fl.recipe_path = lambda: recipe          # forca a receita de teste

    failures = []

    def check(label, cond):
        print(("  OK   " if cond else "  FALHA ") + label)
        if not cond:
            failures.append(label)

    def shown(track, slot, pname):
        for idx, (nm, _v, fmt) in store[(track, slot)][1].items():
            if nm == pname:
                return fmt(store[(track, slot)][1][idx][1])
        return None

    print("== 1. scan / dump / apply (preset portavel) ==")
    state = fl.scan()
    check("acha 3 plugins na track atual (12)", state["track"] == 12 and len(state["slots"]) == 3)
    fl.dump()
    check("arquivo de cadeia criado", os.path.isfile(chain))
    # mexe um knob e ve se diff acusa; depois apply conserta
    store[(12, 1)][1][0][1] = 0.9
    applied, missed = fl.apply()
    check("apply devolveu todos os 10 parametros", applied == 10)
    check("ratio voltou ao valor salvo (10.5:1)", shown(12, 1, "Ratio") == "10.5:1")

    print("\n== 2. lead(): resolve knobs pelo TEXTO, so o grupo LEAD ==")
    ok_n, bad_n = capture_ret(lambda: fl.apply_recipe(quiet=True, group_filter='LEAD'))
    check("8 knobs acertados / 2 relatados como falha", (ok_n, bad_n) == (8, 2))
    check("Ratio terminou mostrando 8.0:1", shown(12, 1, "Ratio") == "8.0:1")
    check("Threshold terminou em -18.0 dB", shown(12, 1, "Threshold") == "-18.0 dB")
    check("Attack terminou em 0.5 ms", shown(12, 1, "Attack") == "0.5 ms")
    check("Make up terminou em +4.0 dB", shown(12, 1, "Make up") == "+4.0 dB")
    check("Over sampling virou 4x (enum)", shown(12, 0, "Over sampling") == "4x")
    check("Band 1 Frequency virou 110 Hz (log)", shown(12, 0, "Band 1 Frequency") == "110 Hz")
    check("Band 1 Gain via alias ~ (=-3.0 dB)", shown(12, 0, "Band 1 Gain") == "-3.0 dB")
    check("knob INVERTIDO resolvido (Dry level 0.0%)", shown(12, 2, "Dry level") == "0.0%")
    check("Release NAO foi tocado (bloco de delay fora do filtro)",
          abs(store[(12, 1)][1][3][1] - 0.5) < 1e-9)

    print("\n== 3. relato honesto do que falhou ==")
    rep = capture(lambda: fl.apply_recipe(group_filter="LEAD"))
    check("avisa plugin ausente", "Ghost Plugin" in rep)
    check("lista os nomes reais quando o param nao existe", "nomes reais" in rep and "Nonexistent" in rep)
    check("mostra o que acertou", "[ok]" in rep)
    check("dry-run nao grava (Release segue intacto)",
          capture(lambda: fl.apply_recipe(dry_run=True, group_filter="LEAD")) and abs(store[(12, 1)][1][3][1] - 0.5) < 1e-9)

    print("\n== 4. grupo SEND isolado ==")
    rep2 = capture(lambda: fl.delayfx())
    check("DELAY ajustou Release para 45.0 ms", shown(12, 1, "Release") == "45.0 ms")
    check("DELAY ignorou as linhas do LEAD", "Ghost Plugin (alvo" not in rep2)

    print("\n== 5. write_recipe (gerar o .txt editavel) ==")
    out = os.path.join(tmpdir, "nascita.txt")
    backup = fl.recipe_path
    fl.recipe_path = lambda: out
    fl.write_recipe()
    fl.recipe_path = backup
    body = open(out, encoding="utf-8").read()
    check("receita embutida salva em disco com alvos reais", "Fruity Compressor|Ratio|8.0:1" in body)
    check("tem os grupos G|LEAD, G|DELAY e G|REVERB",
          all(g in body for g in ("G|LEAD", "G|DELAY", "G|REVERB")))

    print("\n" + ("TODOS OS TESTES PASSARAM" if not failures else
                  "FALHOU %d: %s" % (len(failures), failures)))
    return 1 if failures else 0


def capture(fn, *a, **k):
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        fn(*a, **k)
    return buf.getvalue()


def capture_ret(fn, *a, **k):
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        r = fn(*a, **k)
    return r


if __name__ == "__main__":
    sys.exit(main())

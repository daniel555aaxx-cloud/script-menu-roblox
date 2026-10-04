# -*- coding: utf-8 -*-
"""
Teste offline do fl_chain_tool.py (nao precisa do FL Studio).

Ele simula os modulos embutidos `plugins` e `mixer` do FL Studio e confere se:
  - scan() acha os plugins nos slots certos;
  - dump() grava o estado em texto;
  - apply() devolve os knobs (mesmo com slots fora de ordem / nomes com variacao);
  - diff() acusa diferenca e depois fica limpo.

Rodar:  python3 test_fl_chain_tool.py   (na pasta desta pasta)
"""

import os
import sys
import types
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


# ---------------------------------------------------------------- mock do FL
def make_fl_mock():
    store = {}   # (track, slot) -> [plugin_name, {idx: (name, value, text)}]

    def reg(track, slot, name, params):
        store[(track, slot)] = [name, dict(params)]

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
        return (p[2] or "") if p else ""

    def setParamValue(value, paramIndex, index, slotIndex=-1, pickupMode=0, useGlobalIndex=False):
        params = store[(index, slotIndex)][1]
        assert paramIndex in params, "param %d inexistente no slot %d" % (paramIndex, slotIndex)
        old = params[paramIndex]
        params[paramIndex] = (old[0], float(value), old[2])

    for fn in ("isValid", "getPluginName", "getParamCount", "getParamName",
               "getParamValue", "getParamValueString", "setParamValue"):
        setattr(plugins, fn, locals()[fn])

    mixer = types.ModuleType("mixer")
    mixer.trackNumber = lambda: 12

    return plugins, mixer, store


def main():
    plugins, mixer, store = make_fl_mock()

    # cadeia "gravada" na track 12: nota o furo no slot 2 (plugin desligado/ausente)
    def reg(track, slot, name, params):
        store[(track, slot)] = [name, dict(params)]

    reg(12, 0, "Fruity Parametric EQ 2", {
        0: ("Over sampling", 0.30, "4x"),
        1: ("Linear phase", 0.00, "Off"),
        2: ("Gain", 0.55, "-1.5 dB"),
    })
    reg(12, 1, "Fruity Compressor", {
        0: ("Ratio", 0.80, "8.0:1"),
        1: ("Threshold", 0.35, "-18.0 dB"),
        2: ("Attack", 0.01, "0.5 ms"),
        3: ("Release", 0.40, "45 ms"),
        4: ("Make up", 0.60, "+4.0 dB"),
    })
    reg(12, 3, "MAutoPitch", {
        0: ("Hard tune", 1.00, "On"),
        1: ("Depth", 1.00, "100%"),
        2: ("Speed", 0.05, "1 ms"),
    })
    sys.modules["plugins"] = plugins
    sys.modules["mixer"] = mixer

    import fl_chain_tool as fl

    tmp = os.path.join(tempfile.mkdtemp(prefix="gelachain-"), "chain.txt")
    fl.set_path(tmp)
    failures = []

    def check(label, cond):
        print(("  OK   " if cond else "  FALHA ") + label)
        if not cond:
            failures.append(label)

    print("== 1. scan / leitura da track selecionada ==")
    state = fl.scan()
    check("pega a track atual (12) do mixer", state["track"] == 12)
    check("acha 3 plugins mesmo com slot 2 vazio", len(state["slots"]) == 3)

    print("\n== 2. dump ==")
    fl.dump()
    check("arquivo de preset criado", os.path.isfile(tmp))
    body = open(tmp, encoding="utf-8").read()
    check("formato assinado", body.startswith("# FL-GELA-CHAIN v1"))
    check("valor legivel salvo (-18.0 dB)", "-18.0 dB" in body)

    print("\n== 3. quebra de ordem dos slots ==")
    # move MAutoPitch do slot 3 para o 0 e o EQ para o 3 (o apply deve casar por nome)
    eq = store.pop((12, 0))
    auto = store.pop((12, 3))
    store[(12, 0)] = auto
    store[(12, 3)] = eq

    print("\n== 4. mexe tudo, diff acusa, apply conserta ==")
    store[(12, 1)][1][1] = ("Threshold", 0.95, "-2.0 dB")   # alguem girou o knob
    d1 = capture(fl.diff)
    check("diff acusa diferenca", "Threshold" in d1)
    applied, missed = fl.apply()
    check("todos os 11 parametros aplicados", applied == 11)
    check("threshold voltou para 0.35", abs(store[(12, 1)][1][1][1] - 0.35) < 1e-6)
    check("plugin achado mesmo em slot novo (Hard tune no slot 0)",
          "Hard tune" in str(store[(12, 0)][1]))
    d2 = capture(fl.diff)
    check("diff limpo depois do apply", "diferenca" not in d2)

    print("\n== 5. robustez ==")
    a, m = fl.apply(track=99)
    check("track vazia nao derruba o script", a == 0 and m == 11)
    check("apply em track vazia nao cria arquivo", os.path.isfile(tmp))
    txt = fl.dumps(fl.read_chain(12))
    reparsed = fl.loads(txt)
    check("round-trip de serializacao preserva contagem",
          sum(len(s["params"]) for s in reparsed["slots"]) == 11)

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


if __name__ == "__main__":
    sys.exit(main())

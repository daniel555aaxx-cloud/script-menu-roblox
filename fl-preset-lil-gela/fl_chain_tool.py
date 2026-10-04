# -*- coding: utf-8 -*-
r"""
fl_chain_tool.py - "preset portavel" para FL Studio
===================================================

O FL Studio NAO aceita preset de plugin de audio escrito a mao (formatos
binarios/proprietarios). Este script resolve isso de outro jeito:
ele le os valores REAIS dos knobs dos plugins que estao na sua track do mixer
e grava num arquivo de texto; depois ele re-aplica esses valores em qualquer
outra track / outro projeto / em outro PC seu.

Fluxo normal de uso:
  1) monta a cadeia na track do vocal (slots 0..N) com os valores do README;
  2) roda dump()        -> gera  fl_gela_chain.txt
  3) em outro projeto:   apply() -> os knobs voltam sozinhos

Funcoes disponiveis:
  scan()              lista os plugins da track (com numero de slots e nome)
  dump(track=None)    salva o estado da cadeia em arquivo de texto
  apply(track=None)   carrega o arquivo e seta todos os knobs
  diff(track=None)    compara o que esta na track vs. o arquivo (auditoria)
  params(slot=None)   imprime nome/valor de cada param de um plugin (aprender indices)
  printChain()        resumo legivel da track

Como rodar dentro do FL Studio
------------------------------
Opcao A - Console de script (FL Studio 2024+ / 21.2+):
    View > Script output (ou Tools > Scripting > Console) e cole:

      exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); scan()
      exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); dump()
      exec(open(r"C:\Users\SEU_USUARIO\Documents\fl_gela\fl_chain_tool.py").read()); apply()

Opcao B - MIDI script (se o console nao existir na sua versao):
    copie esta pasta inteira para
      Documentos\Image-Line\FL Studio\Settings\Hardware\fl_gela\
    renomeie este arquivo para  device_fl_chain_tool.py, e no dialog de MIDI
    (Options > MIDI settings) atribua o script a qualquer entrada MIDI ativa.
    Depois dispare com OnNoteOn (nota C3 = 60 -> scan, C#3 -> dump, D3 -> apply).

Requisitos: FL Studio (Qualquer edicao), Python embutido do FL. Nenhum modulo
externo e usado (nem json / os sao obrigatorios).
"""

FORMAT_TAG = "# FL-GELA-CHAIN v1"
DEFAULT_FILENAME = "fl_gela_chain.txt"
MAX_SLOTS = 20          # FL tem no maximo 10 slots por track; sobra folga
TRAILING_INVALID_STOP = 3

# --------------------------------------------------------------------------
# Acesso tolerante a falhas aos modulos do FL Studio
# --------------------------------------------------------------------------

_PLUGINS = None
_MIXER = None


def _module(name):
    """Pega o modulo do FL Studio sem depender de `import` estar completo."""
    try:
        import sys as _sys
        mod = _sys.modules.get(name)
        if mod is not None:
            return mod
    except Exception:
        pass
    try:
        return __import__(name)
    except Exception:
        return None


def _P():
    """Modulo 'plugins' do FL Studio (params dos efeitos)."""
    global _PLUGINS
    if _PLUGINS is None:
        _PLUGINS = _module("plugins")
    if _PLUGINS is None:
        raise RuntimeError(
            "Modulo 'plugins' nao disponivel - rode este script dentro do FL Studio "
            "(View > Script output / MIDI script)."
        )
    return _PLUGINS


def _M():
    """Modulo 'mixer' do FL Studio (track selecionada)."""
    global _MIXER
    if _MIXER is None:
        _MIXER = _module("mixer")
    return _MIXER


def selected_track():
    mx = _M()
    if mx is not None and hasattr(mx, "trackNumber"):
        try:
            return int(mx.trackNumber())
        except Exception:
            pass
    return 1


# --------------------------------------------------------------------------
# Caminho do arquivo de preset
# --------------------------------------------------------------------------

_PATH_OVERRIDE = [None]


def set_path(path):
    """Forca um caminho explicito (use se o padrao nao servir)."""
    _PATH_OVERRIDE[0] = path
    return _PATH_OVERRIDE[0]


def preset_path():
    if _PATH_OVERRIDE[0]:
        return _PATH_OVERRIDE[0]
    try:
        import os  # nem sempre existe dentro do interpretador embutido
        home = os.path.expanduser("~")
        folder = os.path.join(home, "Documents", "fl_gela")
        try:
            if not os.path.isdir(folder):
                os.makedirs(folder)
            return os.path.join(folder, DEFAULT_FILENAME)
        except Exception:
            return os.path.join(home, DEFAULT_FILENAME)
    except Exception:
        # ultimo recurso: caminho absoluto classico do Windows
        return "fl_gela_chain.txt"


# --------------------------------------------------------------------------
# Leitura do estado da track
# --------------------------------------------------------------------------

def _is_valid(track, slot):
    p = _P()
    try:
        return bool(p.isValid(track, slot))
    except Exception:
        return False


def _name(track, slot):
    p = _P()
    try:
        return p.getPluginName(track, slot) or ""
    except Exception:
        try:
            return p.getPluginName(track, slot, False) or ""
        except Exception:
            return ""


def _param_count(track, slot):
    p = _P()
    try:
        return int(p.getParamCount(track, slot))
    except Exception:
        return 0


def _param_name(track, slot, idx):
    p = _P()
    for kwargs in ({"paramIndex": idx, "index": track, "slotIndex": slot},
                   {"paramIndex": idx, "index": track}):
        try:
            return p.getParamName(**kwargs) or ""
        except Exception:
            continue
    try:
        return p.getParamName(idx, track, slot) or ""
    except Exception:
        return ""


def _param_value(track, slot, idx):
    p = _P()
    try:
        v = p.getParamValue(idx, track, slot)
    except Exception:
        try:
            v = p.getParamValue(idx, track)
        except Exception:
            return None
    try:
        v = float(v)
    except Exception:
        return None
    if v != v:  # NaN
        return None
    return max(0.0, min(1.0, v))


def _param_text(track, slot, idx):
    """Valor legivel ('-12.4 dB'), quando o plugin expoe string."""
    p = _P()
    try:
        s = p.getParamValueString(idx, track, slot)
        s = (s or "").strip()
        return s if s and s != "--" else ""
    except Exception:
        return ""


def read_chain(track=None):
    """-> lista de dicts: {slot, plugin, params:[{idx,name,value,text}]}"""
    if track is None:
        track = selected_track()
    p = _P()
    chain = []
    dead = 0
    for slot in range(MAX_SLOTS):
        if not _is_valid(track, slot):
            dead += 1
            if dead >= TRAILING_INVALID_STOP:
                break
            continue
        dead = 0
        count = _param_count(track, slot)
        params = []
        # VST expoe 4240 params; a maioria vazia. Limitamos a 600 nomes validos.
        checked = 0
        for idx in range(min(count or 600, 600)):
            checked += 1
            if checked > 600:
                break
            nm = _param_name(track, slot, idx)
            if not nm or not nm.strip():
                continue
            val = _param_value(track, slot, idx)
            if val is None:
                continue
            params.append({
                "idx": idx,
                "name": nm.strip(),
                "value": round(val, 6),
                "text": _param_text(track, slot, idx),
            })
        chain.append({
            "slot": slot,
            "plugin": _name(track, slot).strip() or "(sem nome)",
            "params": params,
        })
    return {"track": track, "slots": chain}


# --------------------------------------------------------------------------
# Serializacao (formato de texto simples, sem depender de json)
# --------------------------------------------------------------------------

def _esc(s):
    return (s or "").replace("|", "/").replace("\r", " ").replace("\n", " ").strip()


def _unesc(s):
    return s.replace("/", "|").strip()


def dumps(state):
    out = [FORMAT_TAG,
           "track=%d" % int(state["track"]),
           "# linhas: P|slot|idx|valor(0..1)|plugin|param|mostrado"]
    for sl in state["slots"]:
        plug = _esc(sl["plugin"])
        out.append("S|%d|%s" % (sl["slot"], plug))
        for pr in sl["params"]:
            out.append("P|%d|%d|%.6f|%s|%s|%s" % (
                sl["slot"], pr["idx"], pr["value"], plug,
                _esc(pr["name"]), _esc(pr.get("text", ""))))
    return "\n".join(out) + "\n"


def loads(text):
    state = {"track": 1, "slots": []}
    by_slot = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("track="):
            try:
                state["track"] = int(line.split("=", 1)[1])
            except Exception:
                pass
            continue
        parts = line.split("|")
        if parts[0] == "S" and len(parts) >= 3:
            slot = int(parts[1])
            entry = {"slot": slot, "plugin": _unesc(parts[2]), "params": []}
            by_slot[slot] = entry
            state["slots"].append(entry)
        elif parts[0] == "P" and len(parts) >= 6:
            try:
                slot = int(parts[1])
                idx = int(parts[2])
                val = float(parts[3])
            except Exception:
                continue
            entry = by_slot.get(slot)
            if entry is None:
                entry = {"slot": slot, "plugin": _unesc(parts[4]), "params": []}
                by_slot[slot] = entry
                state["slots"].append(entry)
            entry["params"].append({
                "idx": idx,
                "value": max(0.0, min(1.0, val)),
                "name": _unesc(parts[5]),
                "text": _unesc(parts[6]) if len(parts) > 6 else "",
            })
    return state


def write_file(state, path=None):
    path = path or preset_path()
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(dumps(state))
    return path


def read_file(path=None):
    path = path or preset_path()
    with open(path, "r", encoding="utf-8") as fh:
        return loads(fh.read())


# --------------------------------------------------------------------------
# Aplicar valores
# --------------------------------------------------------------------------

def _norm(s):
    return "".join(ch for ch in (s or "").lower() if ch.isalnum())


def _find_slot_by_name(state, wanted):
    target = _norm(wanted)
    for sl in state["slots"]:
        if _norm(sl["plugin"]) == target:
            return sl
    for sl in state["slots"]:
        n = _norm(sl["plugin"])
        if target and (target in n or n in target):
            return sl
    return None


def apply(track=None, path=None, by_name=True):
    """Seta todos os knobs da track a partir do arquivo salvo.

    by_name=True casa plugins pelo nome (tolera slot fora de ordem);
    by_name=False usa o numero de slot gravado no arquivo.
    """
    if track is None:
        track = selected_track()
    state = read_file(path)
    p = _P()
    ok = miss = 0
    live = read_chain(track)
    for sl in state["slots"]:
        slot = sl["slot"]
        if by_name:
            found = _find_slot_by_name(live, sl["plugin"])
            if found:
                slot = found["slot"]
            else:
                print("  [x] plugin ausente na track: %s" % sl["plugin"])
                miss += len(sl["params"])
                continue
        if not _is_valid(track, slot):
            print("  [x] slot %d vazio (esperava %s)" % (slot, sl["plugin"]))
            miss += len(sl["params"])
            continue
        live_names = {}
        for idx in range(min(_param_count(track, slot) or 600, 600)):
            nm = _param_name(track, slot, idx)
            if nm and nm.strip():
                live_names[_norm(nm)] = idx
        for pr in sl["params"]:
            idx = pr["idx"]
            if by_name:
                hit = live_names.get(_norm(pr["name"]))
                if hit is not None:
                    idx = hit
            try:
                p.setParamValue(pr["value"], idx, track, slot)
                ok += 1
            except Exception:
                try:
                    p.setParamValue(pr["value"], idx, track)
                    ok += 1
                except Exception:
                    miss += 1
        print("  [ok] slot %d - %s" % (slot, sl["plugin"]))
    print("apply: %d parametros aplicados, %d ignorados (track %d)." % (ok, miss, track))
    return ok, miss


def diff(track=None, path=None):
    """Mostra diferenca (em % do curso do knob) entre a track e o arquivo."""
    if track is None:
        track = selected_track()
    saved = read_file(path)
    live = read_chain(track)
    live_by_name = {_norm(s["plugin"]): s for s in live["slots"]}
    total = 0
    for sl in saved["slots"]:
        cur = live_by_name.get(_norm(sl["plugin"]))
        if cur is None:
            print("[faltando] %s" % sl["plugin"])
            continue
        cur_by_idx = {pr["idx"]: pr for pr in cur["params"]}
        for pr in sl["params"]:
            c = cur_by_idx.get(pr["idx"])
            if c is None:
                continue
            d = abs(c["value"] - pr["value"])
            total += 1
            if d > 0.005:
                print("[%.0f%% de diferenca] %s > %s  (salvo=%s | agora=%s)" % (
                    d * 100.0, sl["plugin"], pr["name"],
                    pr["text"] or "%.3f" % pr["value"],
                    c["text"] or "%.3f" % c["value"]))
    print("diff: %d parametros conferidos na track %d." % (total, track))


# --------------------------------------------------------------------------
# Utilitarios de inspecao
# --------------------------------------------------------------------------

def scan(track=None):
    if track is None:
        track = selected_track()
    st = read_chain(track)
    print("== Track %d ==" % st["track"])
    if not st["slots"]:
        print("  nenhum plugin encontrado. Selecione a track do vocal no mixer e rode de novo.")
    for sl in st["slots"]:
        print("  slot %d  %-34s %d parametros" % (sl["slot"], sl["plugin"], len(sl["params"])))
    return st


def params(slot, track=None):
    if track is None:
        track = selected_track()
    st = read_chain(track)
    for sl in st["slots"]:
        if sl["slot"] == slot:
            print("== %s (slot %d) ==" % (sl["plugin"], slot))
            for pr in sl["params"]:
                print("  idx %-4d %-28s %s" % (pr["idx"], pr["name"],
                                               pr["text"] or "%.3f" % pr["value"]))
            return sl
    print("slot %d vazio" % slot)


def printChain(track=None):
    scan(track)


def dump(track=None, path=None):
    if track is None:
        track = selected_track()
    st = read_chain(track)
    if not st["slots"]:
        print("nada para salvar: a track %d nao tem plugins." % track)
        return None
    written = write_file(st, path)
    total = sum(len(s["params"]) for s in st["slots"])
    print("dump: %d plugins / %d parametros -> %s" % (len(st["slots"]), total, written))
    print("para re-aplicar: apply()   (a track selecionada no mixer e a alvo)")
    return written


# --------------------------------------------------------------------------
# Ganchos de MIDI script (só usados na Opcao B)
# --------------------------------------------------------------------------

TRIGGER_SCAN, TRIGGER_DUMP, TRIGGER_APPLY = 60, 61, 62


def OnRefresh(flags):
    pass


def OnNoteOn(event):
    try:
        note = int(event.data1)
        if note == TRIGGER_SCAN:
            scan()
        elif note == TRIGGER_DUMP:
            dump()
        elif note == TRIGGER_APPLY:
            apply()
        else:
            return
        event.handled = True
    except Exception as exc:
        print("erro no trigger: %r" % (exc,))


if __name__ == "__main__":
    print("Este modulo roda dentro do FL Studio. Funcoes: scan(), dump(), apply(), diff(), params(slot).")

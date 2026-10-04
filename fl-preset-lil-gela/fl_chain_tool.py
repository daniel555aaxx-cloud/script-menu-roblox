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
  lead() / dobras() / adlibs() / tune() / delayfx() / reverbfx()
                      O PRESET DE VERDADE: giram todos os knobs da receita
                      (receita-gela.txt) na track selecionada no mixer. Nao
                      precisam de arquivo salvo antes - a receita ja vem
                      embutida. Use dry_run=True para so conferir.
                      Se existir receita-gela.txt ao lado, ele tem prioridade.
  write_recipe()      grava a receita embutida em .txt para voce editar
  scan()              lista os plugins da track (slots e nomes)
  dump(track=None)    salva o estado atual da cadeia em arquivo de texto
  apply(track=None)   reaplica exatamente o que foi salvo no dump()
  diff(track=None)    compara o que esta na track vs. o arquivo (auditoria)
  params(slot)        imprime nome/valor de cada param de um plugin
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
    Depois dispare com OnNoteOn (C3=60 scan, C#3 dump, D3 apply, E3 lead).

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


def _os():
    try:
        import os
        return os
    except Exception:
        return None


def _docs_dir():
    """Pasta onde o script grava os arquivos (Documents/fl_gela, com fallbacks)."""
    os = _os()
    if os is None:
        return None
    try:
        home = os.path.expanduser("~")
    except Exception:
        home = "."
    for cand in (
        os.path.join(home, "Documents", "fl_gela"),
        os.path.join(home, "fl_gela"),
        home,
    ):
        try:
            if not os.path.isdir(cand):
                os.makedirs(cand)
            return cand
        except Exception:
            continue
    return None


def preset_path():
    if _PATH_OVERRIDE[0]:
        return _PATH_OVERRIDE[0]
    d = _docs_dir()
    if d:
        try:
            import os
            return os.path.join(d, DEFAULT_FILENAME)
        except Exception:
            pass
    return DEFAULT_FILENAME


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


def recipe_path():
    """Receita editavel (receita-gela.txt) ao lado de fl_gela_chain.txt."""
    os = _os()
    if os is None:
        return "receita-gela.txt"
    try:
        base = os.path.dirname(preset_path())
    except Exception:
        base = "."
    return os.path.join(base, "receita-gela.txt")


def install_recipe(src=None):
    r"""Copia uma receita-gela.txt (a que veio no pacote) para a pasta do FL.

    Uso:  install_recipe(r"C:\Users\VOCE\Downloads\receita-gela.txt")
    Depois disso, lead()/dobras()/... usam a SUA receita editada.
    """
    os = _os()
    dest = recipe_path()
    if not src:
        print('informe o caminho da receita, ex.:')
        print('  install_recipe(r"C:\\Users\\VOCE\\Downloads\\receita-gela.txt")')
        return None
    with open(src, "r", encoding="utf-8") as fh:
        body = fh.read()
    with open(dest, "w", encoding="utf-8") as fh:
        fh.write(body)
    print("receita instalada em: %s" % dest)
    return dest


def write_recipe(path=None):
    """Escreve a receita embutida em disco para voce editar (e o arquivo do preset)."""
    path = path or recipe_path()
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(RECIPE_DEFAULT)
    print("receita escrita em: %s" % path)
    print("edite esse arquivo e rode apply_recipe() de novo.")
    return path


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
# RECEITA: o FL Studio gira os knobs sozinho, a partir de um .txt legivel
# --------------------------------------------------------------------------
# Formato da linha (T = target por texto/valor escrito):
#   T|<plugin>|<param>|<valor como aparece no knob>
# Use "~" para aceitar nomes alternativos:  T|Fruity Compressor|Ratio~Rel?|8.0:1
# Linhas comecam com "#" = comentario. Arquivo editavel em qualquer editor.

RECIPE_LEAD = """# receita-gela.txt - cadeia LEAD do preset "GELA" (edite a vontade)
T|Fruity Parametric EQ 2|Output Gain~-1.5 dB|dummy
"""

RECIPE_DEFAULT = """# =========================================================
#  Preset vocal "GELA" (emo trap BR / lilgiela33) - FL Studio
#  Edite este arquivo: ele e a fonte da verdade do apply_recipe().
#  Formato: T|plugin|parametro|valor (igual esta escrito no knob)
#  Use ~ para nomes alternativos do parametro.
#  OBS: nomes de param mudam um pouco entre versoes do FL. Se uma linha
#  der "[sem alvo]", rode params(slot) e corrija o nome nesta linha.
# =========================================================

# Grupo LEAD = track do vocal. Grupo SEND = track do efeito (reverb/delay).
# apply_recipe() sem grupo aplica TUDO que estiver na track selecionada.
G|LEAD
# --- SLOT: Fruity Parametric EQ 2 (pre-EQ cirurgico) --------------------
T|Parametric EQ 2|Over sampling~Oversampling~Global oversampling|4x
T|Parametric EQ 2|Linear phase~Lin|Off

# --- SLOT: Fruity Compressor (1a etapa: pega os picos) ------------------
T|Fruity Compressor|Ratio|8.0:1
T|Fruity Compressor|Threshold|-18.0 dB
T|Fruity Compressor|Attack|0.5 ms
T|Fruity Compressor|Release|45.0 ms
T|Fruity Compressor|Volume~Make up~Makeup~Output|+4.0 dB

# --- SLOT: Fruity Limiter em modo COMP (2a etapa, serial) ---------------
T|Fruity Limiter|Mode~Type|Comp
T|Fruity Limiter|Comp ratio~Ratio|4.0:1
T|Fruity Limiter|Comp threshold~Threshold|-12.0 dB
T|Fruity Limiter|Comp attack~Attack|3.0 ms
T|Fruity Limiter|Comp release~Release|80.0 ms
T|Fruity Limiter|Auto release|On
T|Fruity Limiter|Comp gain~Gain|+2.0 dB

# --- SLOT: de-esser com Fruity Maximus (crossover 5.5 kHz) --------------
T|Maximus|Band 3 crossover~Crossover 3~Xover 3|5.5 kHz

# --- SLOT: drive ---------------------------------------------------------
T|Soundgoodizer|Amount~Knob|15.0%

# --- DELAY: use com a track do GELA DELAY selecionada --------------------
G|DELAY
T|Delay 3|Time~Delay time|3/16
T|Delay 3|Feedback|25.0%
T|Delay 3|High pass~Hypass|550 Hz
T|Delay 3|Low pass~Lopass|3.2 kHz
T|Delay 3|Ping pong~Ping-pong|On
G|REVERB
T|Reeverb 2|Pre delay~Pre-delay|32.0 ms
T|Reeverb 2|Stereo separation~Sep|45.0%
T|Reeverb 2|Dry level~Dry|0%
"""


def _float_in(text):
    """Primeiro numero escrito em 'text' ('-18.0 dB' -> -18.0). None se nao ha."""
    s = text or ""
    i = 0
    n = len(s)
    while i < n:
        ch = s[i]
        if ch.isdigit() or (ch in "+-" and i + 1 < n and (s[i + 1].isdigit() or s[i + 1] == ".")):
            j = i + 1
            while j < n and (s[j].isdigit() or s[j] == "."):
                j += 1
            frag = s[i:j]
            try:
                return float(frag)
            except Exception:
                i = j
                continue
        i += 1
    return None


def _flat(text):
    return "".join(ch for ch in (text or "").lower() if ch.isalnum())


def _patterns(pattern):
    return [p for p in (_flat(x) for x in (pattern or "").split("~")) if p]


def _match_score(haystack, pats):
    for p in pats:
        if haystack == p:
            return 3
        if p in haystack:
            return 2
        if haystack and haystack in p:
            return 1
    return 0


_LIVE_CACHE = {}


def _live_params(track, slot, refresh=False):
    key = (track, slot)
    if refresh or key not in _LIVE_CACHE:
        p = _P()
        count = _param_count(track, slot)
        items = []
        for idx in range(min(count or 600, 600)):
            nm = _param_name(track, slot, idx)
            if nm and nm.strip():
                items.append((idx, nm.strip()))
        _LIVE_CACHE[key] = items
    return _LIVE_CACHE[key]


def _closest(actual, wanted_pats, n=6):
    scored = []
    for idx, nm in actual:
        f = _flat(nm)
        s = _match_score(f, wanted_pats)
        scored.append((s, -abs(len(f) - 8), idx, nm))
    scored.sort(reverse=True)
    return [nm for s, x, idx, nm in scored[:n]]


def _read_text(track, slot, idx):
    txt = _param_text(track, slot, idx)
    return txt if txt else ""


def _probe_set(track, slot, idx, value):
    p = _P()
    try:
        p.setParamValue(value, idx, track, slot)
    except Exception:
        try:
            p.setParamValue(value, idx, track)
        except Exception:
            return None
    return _read_text(track, slot, idx)


def _solve(track, slot, idx, target):
    """Acha o valor interno (0..1) que faz o knob MOSTRAR 'target'.

    1) varre 65 posicoes procurando o texto bater exato (cobre enums: On/Off/4x/Comp)
    2) senao, assume curva monotonicas e faz bisseccao pelo numero (cobre Hz/dB/ms/%)
    Devolve (value, shown, ok).
    """
    tflat = _flat(target)
    tnum = _float_in(target)

    # 1) bate-texto
    STEPS = 65
    best_text = None
    best_num = None
    for k in range(STEPS + 1):
        v = k / float(STEPS)
        shown = _probe_set(track, slot, idx, v)
        if shown is None:
            return (None, "knob nao responde", False)
        if _flat(shown) == tflat:
            best_text = (v, shown)
            break
        if tnum is not None:
            sv = _float_in(shown)
            if sv is not None:
                d = abs(sv - tnum)
                if best_num is None or d < best_num[2]:
                    best_num = (v, shown, d)
    if best_text:
        return (best_text[0], best_text[1], True)

    # sem resposta de texto exata -> bisseccao numerica em torno do melhor ponto
    if tnum is None:
        if best_num is None:
            return (None, "plugin nao expoe o valor como texto", False)
        return (best_num[0], best_num[1], abs(best_num[2]) <= max(0.06, abs(tnum) * 0.01))
    if best_num is None:
        return (None, "plugin nao expoe o valor como texto", False)

    lo = max(0.0, best_num[0] - 2.0 / STEPS)
    hi = min(1.0, best_num[0] + 2.0 / STEPS)
    cur_v, cur_s, cur_d = best_num

    # inclinacao do knob (alguns sao invertidos: subir o knob reduz o dB)
    increasing = True
    base = _float_in(cur_s or "")
    other = _float_in(_probe_set(track, slot, idx, min(1.0, cur_v + 4.0 / STEPS)) or "")
    if base is not None and other is not None and other != base:
        increasing = other > base

    tol = max(0.06, abs(tnum) * 0.01)
    for _ in range(40):
        if hi - lo < 1e-7:
            break
        mid = 0.5 * (lo + hi)
        shown = _probe_set(track, slot, idx, mid)
        sv = _float_in(shown or "")
        if sv is None:
            break
        d = abs(sv - tnum)
        if d < cur_d:
            cur_v, cur_s, cur_d = mid, shown, d
        if d <= 1e-9:
            break
        if (sv > tnum) == increasing:
            hi = mid
        else:
            lo = mid

    return (cur_v, cur_s, cur_d <= tol)


def fx(group, track=None, dry_run=False, quiet=False):
    """Aplica apenas o bloco G|<group> da receita na track selecionada no mixer."""
    return apply_recipe(track=track, dry_run=dry_run, quiet=quiet, group_filter=group)


def lead(track=None, dry_run=False):
    """Bloco LEAD (track do vocal): EQ, compressores, de-esser, drive.

    lead(dry_run=True) so mostra o que ele encontrou, sem gravar.
    """
    return fx('LEAD', track=track, dry_run=dry_run)


def dobras(track=None, dry_run=False):
    """Bloco DOBRAS (track 13 - refrao empilhado)."""
    return fx('DOBRAS', track=track, dry_run=dry_run)


def adlibs(track=None, dry_run=False):
    """Bloco ADLIBS (track 14 - grito/ad-lib com mais drive)."""
    return fx('ADLIBS', track=track, dry_run=dry_run)


def tune(track=None, dry_run=False):
    """Bloco TUNE (MAutoPitch na track do vocal)."""
    return fx('TUNE', track=track, dry_run=dry_run)


def delayfx(track=None, dry_run=False):
    """Bloco DELAY (use com a track do GELA DELAY selecionada)."""
    return fx('DELAY', track=track, dry_run=dry_run)


def reverbfx(track=None, dry_run=False):
    """Bloco REVERB (use com a track do GELA REVERB selecionada)."""
    return fx('REVERB', track=track, dry_run=dry_run)


def load_recipe(path=None):
    path = path or recipe_path()
    try:
        fh = open(path, "r", encoding="utf-8")
    except Exception:
        return [ln for ln in RECIPE_DEFAULT.splitlines() if ln.strip()], "(embutida no script)"
    with fh:
        return [ln for ln in fh.read().splitlines() if ln.strip()], path


def apply_recipe(track=None, path=None, dry_run=False, quiet=False, group_filter=None):
    """Seta TODOS os knobs da track a partir da receita (o texto do knob).

    dry_run=True -> so mostra o que ele encontrou, sem gravar (para 'ler' o alvo o
                     script movimenta o knob: faca com o transporte parado).
    """
    global _LIVE_CACHE
    _LIVE_CACHE = {}
    if track is None:
        track = selected_track()
    lines, origin = load_recipe(path)
    entries = []
    group = 'LEAD'
    for ln in lines:
        ln = ln.strip()
        if ln.startswith('G|'):
            group = ln[2:].strip().upper() or 'LEAD'
            continue
        if not ln.startswith('T|'):
            continue
        parts = ln.split('|')
        if len(parts) < 4:
            continue
        entries.append((group, parts[1].strip(), parts[2].strip(),
                        '|'.join(parts[3:]).strip()))
    if group_filter:
        gf = group_filter.strip().upper()
        entries = [e for e in entries if e[0] == gf]

    live = read_chain(track)
    by_plugin = {}
    for sl in live['slots']:
        by_plugin[_flat(sl['plugin'])] = sl
    ok_rows = []
    bad_rows = []
    if not quiet:
        print('receita: %s | track %d | %d linhas' % (origin, track, len(entries)))
        names = ', '.join(sl['plugin'] for sl in live['slots'])
        print('plugins na track: %s' % (names or '(nenhum)'))

    for _grp, plug_pat, par_pat, target in entries:
        pats = _patterns(plug_pat)
        slot = None
        for flat_name, sl in by_plugin.items():
            if _match_score(flat_name, pats):
                slot = sl['slot']
                break
        if slot is None:
            bad_rows.append('plugin ausente: %s (alvo %s)' % (plug_pat, target))
            continue
        actual = _live_params(track, slot)
        ppats = _patterns(par_pat)
        hits = [idx for idx, nm in actual if _match_score(_flat(nm), ppats) == 3]
        if not hits:
            hits = [idx for idx, nm in actual if _match_score(_flat(nm), ppats) >= 2]
        if not hits:
            bad_rows.append('%s > param %s nao existe. nomes reais: %s' % (
                plug_pat, par_pat, ', '.join(_closest(actual, ppats))))
            continue
        idx = hits[0]
        pname = ''
        for i, nm in actual:
            if i == idx:
                pname = nm
        if dry_run:
            before = _read_text(track, slot, idx)
            value, shown, ok = _solve(track, slot, idx, target)
            cur = _param_value(track, slot, idx)
            _probe_set(track, slot, idx, cur if cur is not None else 0.5)
            msg = '%s > %s: de [%s] para [%s] (slot %d)' % (
                plug_pat, pname, before, shown, slot)
            (ok_rows if ok else bad_rows).append(msg if ok else msg + ' [sem alvo]')
            continue
        value, shown, ok = _solve(track, slot, idx, target)
        if ok and value is not None:
            _probe_set(track, slot, idx, value)
            ok_rows.append('%s > %s = [%s] (slot %d)' % (plug_pat, pname, shown, slot))
        else:
            bad_rows.append('%s > alvo [%s] nao alcancado (ultimo visto [%s])' % (
                plug_pat, target, shown))

    for row in ok_rows:
        if not quiet:
            print('  [ok] ' + row)
    for row in bad_rows:
        if not quiet:
            print('  [!!] ' + row)
    print('apply_recipe: %d knobs acertados, %d pra mexer a mao%s' % (
        len(ok_rows), len(bad_rows), ' (dry-run: nada gravado)' if dry_run else ''))
    if bad_rows and not quiet:
        print('Dica: params(<slot>) lista os nomes reais do plugin; corrija a linha no .txt da receita.')
    return len(ok_rows), len(bad_rows)


# --------------------------------------------------------------------------
# Ganchos de MIDI script (só usados na Opcao B)
# --------------------------------------------------------------------------

TRIGGER_SCAN, TRIGGER_DUMP, TRIGGER_APPLY, TRIGGER_LEAD = 60, 61, 62, 64


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
        elif note == TRIGGER_LEAD:
            lead()
        else:
            return
        event.handled = True
    except Exception as exc:
        print("erro no trigger: %r" % (exc,))


if __name__ == "__main__":
    print("Rode dentro do FL Studio. Funcoes: lead(), delayfx(), reverbfx(), write_recipe(),")
    print("scan(), dump(), apply(), diff(), params(slot).")

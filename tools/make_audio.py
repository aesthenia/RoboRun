import numpy as np, wave, subprocess, os, sys

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "audio")
rng = np.random.default_rng(7)


def mtof(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def env(n, a, d, sr=SR, s=0.0, r=None):
    t = np.arange(n) / sr
    e = np.minimum(t / max(a, 1e-4), 1.0)
    dec = np.exp(-np.maximum(t - a, 0) / max(d, 1e-4))
    return e * (s + (1 - s) * dec)


def osc(kind, f, n, sr=SR, phase=0.0):
    t = np.arange(n) / sr
    if np.ndim(f):
        ph = 2 * np.pi * np.cumsum(f) / sr + phase
    else:
        ph = 2 * np.pi * f * t + phase
    if kind == "sine":
        return np.sin(ph)
    if kind == "tri":
        return 2 / np.pi * np.arcsin(np.sin(ph))
    if kind == "saw":
        return 2 * ((ph / (2 * np.pi)) % 1.0) - 1
    if kind == "square":
        return np.sign(np.sin(ph))
    raise ValueError(kind)


def lowpass(x, cutoff, sr=SR):
    a = np.exp(-2 * np.pi * cutoff / sr)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc = (1 - a) * x[i] + a * acc
        y[i] = acc
    return y


def lp_fast(x, cutoff, sr=SR):
    from scipy.signal import lfilter
    a = np.exp(-2 * np.pi * cutoff / sr)
    return lfilter([1 - a], [1, -a], x)


def hp_fast(x, cutoff, sr=SR):
    return x - lp_fast(x, cutoff, sr)


def add(buf, start, sig):
    end = start + len(sig)
    if end <= len(buf):
        buf[start:end] += sig
    else:
        k = len(buf) - start
        buf[start:] += sig[:k]
        rest = sig[k:]
        buf[: len(rest)] += rest


def kick(n=int(0.3 * SR)):
    t = np.arange(n) / SR
    f = 45 + 110 * np.exp(-t / 0.035)
    return osc("sine", f, n) * env(n, 0.002, 0.18) * 0.9


def snare(n=int(0.22 * SR)):
    noise = hp_fast(rng.uniform(-1, 1, n), 1200)
    body = osc("tri", 190, n) * env(n, 0.001, 0.05)
    return (noise * env(n, 0.001, 0.07) * 0.5 + body * 0.35)


def hat(n=int(0.06 * SR), vol=0.18):
    return hp_fast(rng.uniform(-1, 1, n), 7000) * env(n, 0.001, 0.015) * vol


def delay_wrap(x, d_samples, fb, mix):
    y = x.copy()
    tap = x.copy()
    for _ in range(4):
        tap = np.roll(tap, d_samples) * fb
        y += tap * mix
    return y


def render_menu():
    bpm = 84
    beat = 60 / bpm
    bars = 16
    L = int(bars * 4 * beat * SR)
    left = np.zeros(L)
    right = np.zeros(L)
    prog = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
    bass = [45, 41, 48, 43]
    arp = [0, 1, 2, 1, 2, 1, 0, 2]
    for bar in range(bars):
        ch = prog[bar % 4]
        t0 = int(bar * 4 * beat * SR)
        n = int(4 * beat * SR)
        pad = np.zeros(n)
        for m in ch:
            for det in (-0.08, 0.08):
                pad += osc("saw", mtof(m) * (1 + det / 100 * 12), n)
        pad = lp_fast(pad, 900) * env(n, 0.6, 99, s=1.0) * np.minimum(1, (n - np.arange(n)) / (0.4 * SR)) * 0.05
        add(left, t0, pad)
        add(right, t0, pad)
        bn = int(4 * beat * SR)
        b = osc("sine", mtof(bass[bar % 4]), bn) * env(bn, 0.02, 1.6) * 0.32
        add(left, t0, b)
        add(right, t0, b)
        for s in range(8):
            m = ch[arp[s]] + 12 + (12 if bar % 8 >= 4 and s in (3, 7) else 0)
            an = int(beat * 0.9 * SR)
            note = osc("tri", mtof(m), an) * env(an, 0.005, 0.35) * 0.13
            st = t0 + int(s * beat / 2 * SR)
            add(left, st, note * (0.8 if s % 2 else 1.0))
            add(right, st, note * (1.0 if s % 2 else 0.8))
    d = int(beat * 0.75 * SR)
    left = delay_wrap(left, d, 0.45, 0.35)
    right = delay_wrap(right, d + int(0.011 * SR), 0.45, 0.35)
    return left, right


def render_level():
    bpm = 128
    beat = 60 / bpm
    bars = 16
    L = int(bars * 4 * beat * SR)
    left = np.zeros(L)
    right = np.zeros(L)
    roots = [40, 36, 43, 38]
    chords = [[64, 67, 71], [60, 64, 67], [67, 71, 74], [62, 66, 69]]
    lead = [76, None, 79, None, 83, None, 81, 79, 76, None, None, None, 74, None, 76, 78,
            79, None, 83, None, 86, None, 83, 81, 78, None, None, None, 74, None, 76, None]
    K, S = kick(), snare()
    step = beat / 2
    for bar in range(bars):
        t0 = bar * 4 * beat
        root = roots[bar % 4]
        for s in range(8):
            ts = int((t0 + s * step) * SR)
            if s % 2 == 0:
                add(left, ts, K)
                add(right, ts, K)
            if s in (2, 6) and bar >= 2:
                add(left, ts, S * 0.8)
                add(right, ts, S * 0.8)
            h = hat(vol=0.12 if s % 2 == 0 else 0.2)
            add(left, ts, h * 0.7)
            add(right, ts, h)
            bn = int(step * 0.9 * SR)
            m = root + (12 if s % 4 == 3 else 0)
            b = lp_fast(osc("saw", mtof(m), bn), 700) * env(bn, 0.004, 0.12, s=0.35) * 0.32
            add(left, ts, b)
            add(right, ts, b)
            if s in (0, 3, 6) and bar % 4 != 3:
                cn = int(step * 0.8 * SR)
                c = sum(osc("square", mtof(x), cn) for x in chords[bar % 4])
                c = lp_fast(c, 1800) * env(cn, 0.003, 0.09) * 0.035
                add(left, ts, c * 1.1)
                add(right, ts, c * 0.9)
            if bar >= 4:
                idx = (bar % 4) * 8 + s
                m = lead[idx]
                if m:
                    ln = int(step * 0.95 * SR)
                    v = osc("square", mtof(m), ln) * 0.5 + osc("saw", mtof(m) * 1.004, ln) * 0.5
                    v = lp_fast(v, 2600) * env(ln, 0.005, 0.2, s=0.3) * 0.06
                    add(left, ts, v)
                    add(right, ts, v)
    d = int(beat * 0.75 * SR)
    left = left + 0.25 * np.roll(lp_fast(right, 3000), d)
    right = right + 0.25 * np.roll(lp_fast(left, 3000), d)
    return left, right


def normalize(l, r, peak=0.85):
    m = max(np.abs(l).max(), np.abs(r).max())
    return l / m * peak, r / m * peak


def write_wav(path, x, sr):
    x = np.clip(x, -1, 1)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((x * 32767).astype("<i2").tobytes())


def write_ogg(path, l, r):
    tmp = path + ".raw"
    data = np.stack([l, r], 1)
    (np.clip(data, -1, 1) * 32767).astype("<i2").tofile(tmp)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "s16le", "-ar", str(SR), "-ac", "2", "-i", tmp,
                    "-c:a", "libvorbis", "-q:a", "4", path], check=True)
    os.remove(tmp)


SFX_SR = 22050


def sfx_lose():
    n = int(1.1 * SFX_SR)
    out = np.zeros(n)
    for i, m in enumerate([67, 63, 60, 55]):
        st = int(i * 0.18 * SFX_SR)
        k = int(0.45 * SFX_SR)
        f = mtof(m) * np.linspace(1, 0.97, k)
        v = osc("square", f, k, SFX_SR) * 0.5 + osc("tri", f, k, SFX_SR) * 0.5
        v = lp_fast(v, 2000, SFX_SR) * env(k, 0.01, 0.25, SFX_SR) * 0.5
        out[st:st + k] += v[: max(0, min(k, n - st))]
    return out


def sfx_fuse():
    n = int(0.45 * SFX_SR)
    hiss = hp_fast(rng.uniform(-1, 1, n), 3000, SFX_SR)
    crackle = (rng.uniform(0, 1, n) > 0.985) * rng.uniform(-1, 1, n)
    trem = 0.6 + 0.4 * np.sin(2 * np.pi * 22 * np.arange(n) / SFX_SR)
    return (hiss * 0.35 * trem + crackle * 0.6) * env(n, 0.02, 0.3, SFX_SR, s=0.4)


def sfx_charge():
    n = int(0.62 * SFX_SR)
    t = np.arange(n) / SFX_SR
    f = 120 * (330 / 120) ** (t / t[-1])
    trem = 0.55 + 0.45 * np.sin(2 * np.pi * np.cumsum(np.linspace(8, 26, n)) / SFX_SR)
    v = lp_fast(osc("saw", f, n, SFX_SR), 2500, SFX_SR) * trem
    g = np.minimum(1, t / 0.55) ** 2 * np.minimum(1, (t[-1] - t) / 0.05)
    return v * g * 0.6


def read_wav(path):
    with wave.open(path) as w:
        return np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32767


def variant(x, rate, cutoff):
    idx = np.arange(0, len(x) - 1, rate)
    y = np.interp(idx, np.arange(len(x)), x)
    return lp_fast(y, cutoff, SFX_SR) * 1.05


if __name__ == "__main__":
    music = os.path.join(OUT, "music")
    sfx = os.path.join(OUT, "sfx")
    if "music" in sys.argv[1:] or len(sys.argv) == 1:
        write_ogg(os.path.join(music, "menu_loop.ogg"), *normalize(*render_menu(), 0.7))
        write_ogg(os.path.join(music, "level_loop.ogg"), *normalize(*render_level(), 0.85))
    if "sfx" in sys.argv[1:] or len(sys.argv) == 1:
        write_wav(os.path.join(sfx, "lose.wav"), sfx_lose(), SFX_SR)
        write_wav(os.path.join(sfx, "fuse.wav"), sfx_fuse(), SFX_SR)
        write_wav(os.path.join(sfx, "charge.wav"), sfx_charge(), SFX_SR)
        for name, specs in {"boss_hit": [(0.9, 6000), (1.12, 4000)], "shoot": [(0.94, 7000), (1.08, 5000)],
                            "hurt": [(0.92, 6000), (1.1, 5000)]}.items():
            base = read_wav(os.path.join(sfx, name + ".wav"))
            for i, (rate, cut) in enumerate(specs, 2):
                write_wav(os.path.join(sfx, "%s_%d.wav" % (name, i)), variant(base, rate, cut), SFX_SR)

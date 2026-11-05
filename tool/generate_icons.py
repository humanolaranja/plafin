#!/usr/bin/env python3
"""Gera a marca do Plafin: seta de ciclo em volta de uma moeda com um "P".

Uso:   python3 tool/generate_icons.py
Saída: assets/branding/*.png e assets/branding/logo.svg
Depois: dart run flutter_launcher_icons && dart run flutter_native_splash:create

O glifo é desenhado como uma máscara (tinta = 255, vazados = 0). Os vazados
(serrilha, sulco e face da moeda, contraforma do P) mostram o fundo, então a
mesma máscara serve para o ícone completo, a camada frontal do ícone adaptativo
do Android e o ícone monocromático.
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent.parent / "assets" / "branding"
OUT.mkdir(parents=True, exist_ok=True)

SS = 3                       # supersampling
U = 1024                     # tamanho lógico
S = U * SS
C1, C2 = (255, 122, 61), (222, 58, 8)     # gradiente do fundo
INK = (28, 19, 14)                         # tinta do glifo

# Geometria (unidades de 1024)
CX = CY = 512
RING_R, RING_W = 292, 80                   # anel-seta
ARC_A0, ARC_A1 = 38, 316                   # ângulos (graus, horário, y p/ baixo)
HEAD_L, HEAD_H, HEAD_ROUND = 136, 88, 12   # ponta da seta
COIN_R = 186
TEETH, TOOTH_R = 48, 8.5                   # serrilha
FACE_R = COIN_R - 36                       # raio da face da moeda
P_FRAC = 0.64                              # altura do P / diâmetro da face
# "P" em coordenadas locais (0..146 x 0..212)
P_STEM = (0, 0, 56, 212, 10)               # x0, y0, x1, y1, raio
P_BOWL = (0, 0, 146, 146, 58)
P_CORNER = (0, 0, 70, 70, 10)              # mantém a quina superior esquerda reta
P_COUNTER = (58, 38, 112, 108, 26)         # contraforma (vazada)
P_H = 212


def px(v):
    return v * SS


def new_mask():
    return Image.new("L", (S, S), 0)


def circle(d, cx, cy, r, fill):
    d.ellipse([px(cx - r), px(cy - r), px(cx + r), px(cy + r)], fill=fill)


def pol(r, deg, cx=CX, cy=CY):
    a = math.radians(deg)
    return cx + r * math.cos(a), cy + r * math.sin(a)


def arrow_points():
    """Triângulo da ponta (já recuado para os cantos arredondados)."""
    x, y = pol(RING_R, ARC_A1)
    th = math.radians(ARC_A1)
    tx, ty = -math.sin(th), math.cos(th)
    nx, ny = math.cos(th), math.sin(th)
    pts = [(x + tx * HEAD_L, y + ty * HEAD_L),
           (x + nx * HEAD_H, y + ny * HEAD_H),
           (x - nx * HEAD_H, y - ny * HEAD_H)]
    mx = sum(p[0] for p in pts) / 3
    my = sum(p[1] for p in pts) / 3
    ins = []
    for a, b in pts:
        dx, dy = mx - a, my - b
        l = math.hypot(dx, dy)
        ins.append((a + dx / l * HEAD_ROUND * 1.9, b + dy / l * HEAD_ROUND * 1.9))
    return ins


def draw_arrow(d, fill):
    r = RING_R
    box = [px(CX - r - RING_W / 2), px(CY - r - RING_W / 2),
           px(CX + r + RING_W / 2), px(CY + r + RING_W / 2)]
    d.arc(box, ARC_A0, ARC_A1, fill=fill, width=int(px(RING_W)))
    x, y = pol(r, ARC_A0)
    circle(d, x, y, RING_W / 2, fill)                 # ponta arredondada (início)
    ins = arrow_points()
    d.polygon([(px(a), px(b)) for a, b in ins], fill=fill)
    for i in range(3):
        a, b = ins[i], ins[(i + 1) % 3]
        d.line([(px(a[0]), px(a[1])), (px(b[0]), px(b[1]))], fill=fill,
               width=int(px(2 * HEAD_ROUND)))
        circle(d, a[0], a[1], HEAD_ROUND, fill)


def draw_coin(d):
    circle(d, CX, CY, COIN_R, 255)
    for i in range(TEETH):                            # serrilha
        x, y = pol(COIN_R + 3, i * 360 / TEETH)
        circle(d, x, y, TOOTH_R, 0)
    circle(d, CX, CY, COIN_R - 22, 0)                 # sulco
    circle(d, CX, CY, COIN_R - 29, 255)
    circle(d, CX, CY, FACE_R, 0)                      # face


def draw_p(d, tx, ty, f, scale=px):
    def rr(box, fill):
        x0, y0, x1, y1, r = box
        d.rounded_rectangle([scale(tx + x0 * f), scale(ty + y0 * f),
                             scale(tx + x1 * f), scale(ty + y1 * f)],
                            radius=scale(r * f), fill=fill)
    rr(P_STEM, 255)
    rr(P_BOWL, 255)
    rr(P_CORNER, 255)
    rr(P_COUNTER, 0)


def p_placement():
    """Escala e posição do P: centro de massa em x; meio termo em y."""
    k = 3                                             # px por unidade local
    m = Image.new("L", (160 * k, 220 * k), 0)
    draw_p(ImageDraw.Draw(m), 0, 0, 1, scale=lambda v: v * k)
    w, h = m.size
    small = m.resize((w // 6, h // 6), Image.BILINEAR)
    sp = small.load()
    sx = sy = t = 0
    for y in range(small.height):
        for x in range(small.width):
            v = sp[x, y]
            sx += (x + .5) * v
            sy += (y + .5) * v
            t += v
    cx_u = sx / t * 6 / k
    cy_u = sy / t * 6 / k
    f = (2 * FACE_R * P_FRAC) / P_H
    tx = CX - f * cx_u                                # centro de massa no centro
    ty = CY - f * (0.5 * (P_H / 2) + 0.5 * cy_u)      # y: meio termo caixa/massa
    return tx, ty, f


def glyph_mask(scale=1.0):
    m = new_mask()
    d = ImageDraw.Draw(m)
    draw_arrow(d, 255)
    draw_coin(d)
    tx, ty, f = p_placement()
    draw_p(d, tx, ty, f)
    if scale != 1.0:
        n = int(S * scale)
        small = m.resize((n, n), Image.LANCZOS)
        m = new_mask()
        m.paste(small, ((S - n) // 2, (S - n) // 2))
    return m


def gradient():
    small = Image.new("RGB", (256, 256))
    sp = small.load()
    for y in range(256):
        for x in range(256):
            t = (x + y) / 510
            sp[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(C1, C2))
    return small.resize((S, S), Image.BILINEAR)


def down(img):
    return img.resize((U, U), Image.LANCZOS)


def save(img, name):
    img.save(OUT / name, optimize=True)
    print("wrote", name)


def rgba_from_mask(mask, color):
    out = Image.new("RGBA", (S, S), color + (0,))
    out.putalpha(mask)
    return out


def main():
    mask = glyph_mask()

    # 1) Ícone completo, sem transparência (iOS, web, macOS, Windows, loja).
    icon = gradient()
    icon.paste(INK, mask=mask)
    save(down(icon), "icon.png")

    # 2) Logo arredondado, com transparência (dentro do app e splash).
    r = new_mask()
    ImageDraw.Draw(r).rounded_rectangle([0, 0, S - 1, S - 1],
                                        radius=int(S * 0.225), fill=255)
    rounded = icon.convert("RGBA")
    rounded.putalpha(r)
    save(down(rounded), "logo_rounded.png")

    # 3) Android adaptativo: fundo, frente (dentro da zona segura) e monocromático.
    safe = glyph_mask(0.80)
    save(down(gradient()), "icon_background.png")
    fg = rgba_from_mask(safe, INK)
    save(down(fg), "icon_foreground.png")
    save(down(rgba_from_mask(safe, (0, 0, 0))), "icon_monochrome.png")

    # 4) Splash (Android 12+): glifo sobre o círculo laranja configurado.
    save(down(fg), "splash_glyph.png")

    write_svg()


def write_svg():
    f2 = lambda v: round(v, 2)
    ins = arrow_points()
    sx, sy = pol(RING_R, ARC_A0)
    ex, ey = pol(RING_R, ARC_A1)
    teeth = "".join(
        '<circle cx="{}" cy="{}" r="{}" fill="url(#bg)"/>'.format(
            f2(pol(COIN_R + 3, i * 360 / TEETH)[0]),
            f2(pol(COIN_R + 3, i * 360 / TEETH)[1]), TOOTH_R)
        for i in range(TEETH))
    tx, ty, f = p_placement()

    def rect(box, fill):
        x0, y0, x1, y1, r = box
        return (f'<rect x="{x0}" y="{y0}" width="{x1 - x0}" height="{y1 - y0}" '
                f'rx="{r}" fill="{fill}"/>')

    ink = "#%02x%02x%02x" % INK
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <defs>
    <linearGradient id="bg" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="1024" y2="1024">
      <stop offset="0" stop-color="rgb{C1}"/>
      <stop offset="1" stop-color="rgb{C2}"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" rx="230" fill="url(#bg)"/>
  <path d="M{f2(sx)} {f2(sy)}A{RING_R} {RING_R} 0 1 1 {f2(ex)} {f2(ey)}" fill="none" stroke="{ink}" stroke-width="{RING_W}" stroke-linecap="round"/>
  <polygon points="{' '.join(f'{f2(a)},{f2(b)}' for a, b in ins)}" fill="{ink}" stroke="{ink}" stroke-width="{2 * HEAD_ROUND}" stroke-linejoin="round"/>
  <circle cx="{CX}" cy="{CY}" r="{COIN_R}" fill="{ink}"/>
  {teeth}
  <circle cx="{CX}" cy="{CY}" r="{COIN_R - 22}" fill="url(#bg)"/>
  <circle cx="{CX}" cy="{CY}" r="{COIN_R - 29}" fill="{ink}"/>
  <circle cx="{CX}" cy="{CY}" r="{FACE_R}" fill="url(#bg)"/>
  <g transform="translate({f2(tx)} {f2(ty)}) scale({f2(f)})">
    {rect(P_STEM, ink)}
    {rect(P_BOWL, ink)}
    {rect(P_CORNER, ink)}
    {rect(P_COUNTER, 'url(#bg)')}
  </g>
</svg>
'''
    (OUT / "logo.svg").write_text(svg)
    print("wrote logo.svg")


if __name__ == "__main__":
    main()

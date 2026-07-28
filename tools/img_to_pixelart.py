#!/usr/bin/env python3
"""Convierte una imagen a PIXEL ART real, fiel al original.
Pipeline: reducir resolucion (LANCZOS) -> paleta limitada (cuantizacion) ->
opcional dithering / contorno -> exportar el sprite nativo + una vista ampliada.

Uso:
  python3 tools/img_to_pixelart.py entrada.png salida.png --width 160 --colors 24
  opciones: --dither  --outline  --scale 4  (ampliado para previsualizar)
"""
import argparse
from PIL import Image, ImageFilter


def to_pixel_art(src: Image.Image, width: int, colors: int, dither: bool, outline: bool) -> Image.Image:
    src = src.convert("RGBA")
    w, h = src.size
    th = max(1, round(width * h / w))
    # 1) Reducir a la rejilla de pixel art (buen antialias al bajar).
    small = src.resize((width, th), Image.LANCZOS)
    # 2) Cuantizar a una paleta limitada (bordes duros de pixel art).
    rgb = small.convert("RGB")
    d = Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE
    q = rgb.quantize(colors=max(2, colors), method=Image.MEDIANCUT, dither=d).convert("RGBA")
    # Conservar transparencia del original.
    alpha = small.split()[3]
    q.putalpha(alpha)
    # 3) Contorno opcional (oscurece los bordes detectados).
    if outline:
        edges = rgb.convert("L").filter(ImageFilter.FIND_EDGES)
        px = q.load(); ep = edges.load()
        for yy in range(th):
            for xx in range(width):
                if ep[xx, yy] > 60:
                    r, g, b, a = px[xx, yy]
                    px[xx, yy] = (r // 3, g // 3, b // 4, a)
    return q


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--width", type=int, default=160, help="ancho del pixel art en px")
    ap.add_argument("--colors", type=int, default=24, help="colores de la paleta")
    ap.add_argument("--dither", action="store_true")
    ap.add_argument("--outline", action="store_true")
    ap.add_argument("--scale", type=int, default=5, help="factor de ampliacion para la vista previa")
    a = ap.parse_args()

    src = Image.open(a.input)
    art = to_pixel_art(src, a.width, a.colors, a.dither, a.outline)
    art.save(a.output)  # sprite nativo (pixel art)
    if a.scale > 1:
        prev = art.resize((art.width * a.scale, art.height * a.scale), Image.NEAREST)
        base = a.output.rsplit(".", 1)[0]
        prev.save(base + "_preview.png")
    print("Pixel art: %s (%dx%d, %d colores)" % (a.output, art.width, art.height, a.colors))


if __name__ == "__main__":
    main()

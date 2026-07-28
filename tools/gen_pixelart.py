#!/usr/bin/env python3
"""Generador de pixel art real (PNG) por código, paleta limitada y bordes duros.
Cada sprite es una rejilla de caracteres -> color de paleta. '.' = transparente."""
from PIL import Image

PAL = {
    '.': None,
    'k': (33, 24, 27, 255),      # contorno
    # madera
    'w': (138, 90, 48, 255), 'W': (168, 120, 68, 255), 'd': (107, 68, 35, 255),
    # piedra
    's': (107, 102, 96, 255), 'S': (138, 128, 120, 255), 'z': (76, 72, 66, 255),
    # metal
    'm': (138, 148, 162, 255), 'M': (216, 221, 228, 255), 'n': (74, 85, 96, 255),
    # oro
    'o': (232, 194, 74, 255), 'O': (168, 132, 30, 255),
    # cristal/pocion
    'g': (191, 230, 255, 255), 'l': (47, 127, 208, 255), 'L': (111, 176, 230, 255),
    'c': (154, 122, 74, 255),  # corcho
    # cuero / rojo / hojas / arcano
    'h': (154, 90, 48, 255), 'r': (160, 58, 70, 255),
    'e': (59, 122, 52, 255), 'E': (84, 160, 76, 255),
    'a': (79, 208, 200, 255), 'A': (186, 255, 248, 255),
    'p': (232, 194, 74, 255),
}

SPRITES = {}

SPRITES['potion'] = [
    "................",
    "......kkk.......",
    "......kck.......",
    "......kck.......",
    ".....kgggk......",
    ".....kgLgk......",
    "....kglllgk.....",
    "...kglLlllgk....",
    "..kgllllll lgk..".replace(' ', 'l'),
    "..kglllLllllgk..",
    "..kgllllllllgk..",
    "..kgllllllllgk..",
    "...kgllllllgk...",
    "....kglllgk.....",
    ".....kkkkk......",
    "................",
]

SPRITES['sword'] = [
    ".......k........",
    "......kMk.......",
    "......kMk.......",
    "......kMk.......",
    "......kMk.......",
    "......kMk.......",
    "......kMk.......",
    "......kMk.......",
    "....koooook.....",
    ".....kdddk......",
    "......kdk.......",
    "......kdk.......",
    ".....koook......",
    "......kok.......",
    "................",
    "................",
]

SPRITES['shield'] = [
    "...kkkkkkkk.....",
    "..kmMMMMMMmk....",
    "..kMmmmmmmMk....",
    "..kMmnnnnmMk....",
    "..kMmnoonmMk....",
    "..kMmnoonmMk....",
    "..kMmnnnnmMk....",
    "..kMmmmmmmMk....",
    "...kMmmmmMk.....",
    "....kMmmMk......",
    ".....kMMk.......",
    "......kk........",
    "................",
    "................",
    "................",
    "................",
]

SPRITES['coin'] = [
    "................",
    "................",
    "....kkkkkk......",
    "...koooooOk.....",
    "..koOooooOOk....",
    "..koOoppooOk....",
    "..koOoppooOk....",
    "..koOooooOOk....",
    "...kOoooooOk....",
    "....kkkkkkk.....",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
]

# --- tiles 16x16 ---
SPRITES['floor'] = [
    "wwwwwwwwwwwwwwww",
    "WWWWWWWWWWWWWWWW",
    "wwwwwwwwwwwwwwww",
    "wwwwdwwwwwwwdwww",
    "dddddddddddddddd",
    "wwwwwwwwwwwwwwww",
    "wwwwwwwWwwwwwwww",
    "wwdwwwwwwwwwwwdw",
    "dddddddddddddddd",
    "WWWWWWWWWWWWWWWW",
    "wwwwwwwwwwwwwwww",
    "wwwwwwwwwdwwwwww",
    "wwdwwwwwwwwwwwww",
    "dddddddddddddddd",
    "wwwwwwwwwwwwwwww",
    "wwwwwwwwwwwwwwww",
]

SPRITES['wall'] = [
    "SSSSSSSSSSSSSSSS",
    "SssssssSssssssSS",
    "SssssssSssssssSS",
    "zzzzzzzzzzzzzzzz",
    "sSssssssSsssssss",
    "sSssssssSsssssss",
    "sSssssssSsssssss",
    "zzzzzzzzzzzzzzzz",
    "SssssssSssssssSS",
    "SssssssSssssssSS",
    "zzzzzzzzzzzzzzzz",
    "sSssssssSsssssss",
    "sSssssssSsssssss",
    "zzzzzzzzzzzzzzzz",
    "SSSSSSSSSSSSSSSS",
    "SSSSSSSSSSSSSSSS",
]

def render(grid, scale=1):
    h = len(grid)
    w = max(len(r) for r in grid)
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    px = img.load()
    for y, row in enumerate(grid):
        for x in range(w):
            ch = row[x] if x < len(row) else '.'
            col = PAL.get(ch)
            if col:
                px[x, y] = col
    if scale > 1:
        img = img.resize((w * scale, h * scale), Image.NEAREST)
    return img

import os
OUT = os.path.dirname(os.path.abspath(__file__))

# PNGs reales a tamaño nativo
for name, grid in SPRITES.items():
    render(grid, 1).save(os.path.join(OUT, f"px_{name}.png"))

# Hoja de previsualización ampliada (x16) con fondo
names = list(SPRITES.keys())
cell = 16 * 16 + 24
cols = 4
rows = (len(names) + cols - 1) // cols
sheet = Image.new('RGBA', (cols * cell, rows * cell), (36, 30, 24, 255))
for i, name in enumerate(names):
    big = render(SPRITES[name], 16)
    cx = (i % cols) * cell + 12
    cy = (i // cols) * cell + 12
    sheet.alpha_composite(big, (cx, cy))
sheet.save(os.path.join(OUT, "preview.png"))
print("Generados:", ", ".join(f"px_{n}.png" for n in names))
print("Preview: preview.png")

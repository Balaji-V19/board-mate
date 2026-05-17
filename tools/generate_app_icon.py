#!/usr/bin/env python3
"""Generate BoardMate app-icon master PNGs.

The design mirrors the splash screen: ivory background, a soft cream/gold
glow circle, and the brand die in the centre with five white pips.

Produces two files under assets/icons/:

- app_icon.png             1024×1024 full-bleed icon (used for iOS legacy
                           launcher icons and Android non-adaptive).
- app_icon_foreground.png  1024×1024 transparent. The die plus its glow
                           live inside the inner 66% so the Android adaptive
                           mask (circle / squircle / teardrop) never clips
                           into the die.

Re-run after tweaking colours/sizes:
    python3 tools/generate_app_icon.py
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

# Brand palette — matches lib/config/constants/app_colors.dart
GOLD = (0xB8, 0x86, 0x0B, 0xFF)
IVORY = (0xFF, 0xFF, 0xF0, 0xFF)
WHITE = (255, 255, 255, 255)

SIZE = 1024
OUT = Path(__file__).resolve().parent.parent / "assets" / "icons"


def rounded_square(canvas: Image.Image, cx: float, cy: float, size: float,
                   radius: float, fill):
    """Draw a filled rounded square centred at (cx, cy)."""
    left = cx - size / 2
    top = cy - size / 2
    right = cx + size / 2
    bottom = cy + size / 2
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle([left, top, right, bottom],
                           radius=radius, fill=fill)


def pip_quincunx(draw: ImageDraw.ImageDraw, cx: float, cy: float,
                 die_size: float, pip_radius: float, color):
    """Five pips in a quincunx pattern inside the die centred at (cx, cy)."""
    inset = die_size * 0.22
    positions = [
        (cx - die_size / 2 + inset, cy - die_size / 2 + inset),
        (cx + die_size / 2 - inset, cy - die_size / 2 + inset),
        (cx, cy),
        (cx - die_size / 2 + inset, cy + die_size / 2 - inset),
        (cx + die_size / 2 - inset, cy + die_size / 2 - inset),
    ]
    for (x, y) in positions:
        draw.ellipse(
            [x - pip_radius, y - pip_radius, x + pip_radius, y + pip_radius],
            fill=color,
        )


def draw_die(canvas: Image.Image, cx: float, cy: float, die_size: float):
    """Compose the gold die with a soft shadow and white pips."""
    # Soft shadow behind the die
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [cx - die_size / 2, cy - die_size / 2 + die_size * 0.08,
         cx + die_size / 2, cy + die_size / 2 + die_size * 0.08],
        radius=die_size * 0.22,
        fill=(GOLD[0], GOLD[1], GOLD[2], 90),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=die_size * 0.08))
    canvas.alpha_composite(shadow)

    # Die body
    rounded_square(canvas, cx, cy, die_size, radius=die_size * 0.22, fill=GOLD)

    # Pips
    pip_quincunx(ImageDraw.Draw(canvas), cx, cy, die_size,
                 pip_radius=die_size * 0.085, color=WHITE)


def draw_glow(canvas: Image.Image, cx: float, cy: float, radius: float):
    """Soft cream/gold halo behind the die."""
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=(GOLD[0], GOLD[1], GOLD[2], 36),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=radius * 0.10))
    canvas.alpha_composite(glow)


def main():
    OUT.mkdir(parents=True, exist_ok=True)

    # ── Full-bleed icon (iOS + Android legacy) ──
    cx = cy = SIZE / 2
    icon = Image.new("RGBA", (SIZE, SIZE), IVORY)
    draw_glow(icon, cx, cy, radius=SIZE * 0.38)
    draw_die(icon, cx, cy, die_size=SIZE * 0.34)
    icon.save(OUT / "app_icon.png", "PNG", optimize=True)

    # ── Adaptive foreground (Android) ──
    # Keep all content inside the inner 66% so masks can't clip the die.
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_glow(fg, cx, cy, radius=SIZE * 0.30)
    draw_die(fg, cx, cy, die_size=SIZE * 0.28)
    fg.save(OUT / "app_icon_foreground.png", "PNG", optimize=True)

    print(f"Wrote: {OUT/'app_icon.png'}")
    print(f"Wrote: {OUT/'app_icon_foreground.png'}")


if __name__ == "__main__":
    main()

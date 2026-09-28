"""Draw ScrubbyWurd.ico: a page with lines of text, some blacked out.

    python tools/make-icon.py

Needs Pillow (pip install pillow). Writes ScrubbyWurd.ico next to ScrubbyWurd.html.
"""
import pathlib

from PIL import Image, ImageDraw

OUT = pathlib.Path(__file__).resolve().parent.parent / "ScrubbyWurd.ico"
S = 1024  # drawn large, then scaled down for each icon size

BLUE = (37, 99, 235, 255)     # the Light theme's accent
PAGE = (255, 255, 255, 255)
TEXT = (160, 170, 190, 255)
INK = (28, 28, 31, 255)


def draw() -> Image.Image:
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((40, 40, S - 40, S - 40), radius=200, fill=BLUE)
    d.rounded_rectangle((210, 150, S - 210, S - 150), radius=60, fill=PAGE)
    # Lines of text: (start, end, blacked out?)
    lines = [(270, 750, False), (270, 580, True), (270, 750, False), (270, 460, False), (480, 750, True), (270, 650, False)]
    y = 250
    for x0, x1, redacted in lines:
        h = 70 if redacted else 38
        top = y - (h - 38) // 2
        d.rounded_rectangle((x0, top, x1, top + h), radius=h // 2 if not redacted else 14, fill=INK if redacted else TEXT)
        y += 100
    return img


if __name__ == "__main__":
    draw().save(OUT, sizes=[(16, 16), (20, 20), (24, 24), (32, 32), (40, 40), (48, 48), (64, 64), (128, 128), (256, 256)])
    print(f"wrote {OUT}")

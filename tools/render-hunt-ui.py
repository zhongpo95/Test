# 실제 JASS 모의 프레임 좌표와 기존 TGA를 조합하여 정적 UI 미리보기와 글자 경계 보고서를 만든다.
import json
import re
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/expedition/hunt-ui"
OUT.mkdir(parents=True, exist_ok=True)
FONT = Path("C:/Windows/Fonts/malgun.ttf")
overflow = []
scenes = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
for scene in scenes:
    canvas = Image.new("RGBA", (1600, 900), "#203442")
    draw = ImageDraw.Draw(canvas)
    for frame in sorted(scene["frames"], key=lambda f: (f["priority"], f["id"])):
        x, y = round(frame["x"] * 2000), round(frame["y"] * 1500)
        w, h = max(1, round(frame.get("w", 0) * 2000)), max(1, round(frame.get("h", 0) * 1500))
        if frame["type"] == "BACKDROP":
            texture = ROOT / frame.get("texture", "").replace("\\", "/")
            if not texture.is_file():
                texture = ROOT / "assets/expedition/polish/imports" / texture.name
            if texture.is_file():
                asset = Image.open(texture).convert("RGBA").resize((w, h))
                canvas.alpha_composite(asset, (x, y))
            else:
                draw.rectangle((x, y, x + w, y + h), fill="#cceaf5", outline="#6c9bae")
                draw.text((x + 3, y + 3), "아이콘", font=ImageFont.truetype(str(FONT), max(10, min(w // 3, 16))), fill="#315a70")
            continue
        font = ImageFont.truetype(str(FONT), max(10, round(frame.get("size", .01) * 1500)))
        lines, current, color, offset = [], [], "#315a70", 0
        for token in re.split(r"(\|c[0-9a-fA-F]{8}|\|r|\|n)", frame.get("text", "")):
            if token.startswith("|c"):
                color = "#" + token[-6:]
            elif token == "|r":
                color = "#315a70"
            elif token == "|n":
                lines.append(current)
                current, offset = [], 0
            else:
                for char in token:
                    length = draw.textlength(char, font=font)
                    if offset + length > w and current:
                        lines.append(current)
                        current, offset = [], 0
                    current.append((offset, char, color))
                    offset += length
        lines.append(current)
        line_height = round(font.size * 1.25)
        if len(lines) * line_height > h + 3:
            overflow.append({"scene": scene["name"], "frame": frame["id"], "text": frame.get("text"), "lines": len(lines), "height": h, "estimated": len(lines) * line_height})
        for index, line in enumerate(lines):
            shift = 0
            if frame.get("horizontal") == 5 and line:
                shift = max(0, w - line[-1][0] - draw.textlength(line[-1][1], font=font))
            for offset, char, color in line:
                draw.text((x + shift + offset, y + index * line_height), char, font=font, fill=color)
    canvas.convert("RGB").save(OUT / ("preview-" + scene["name"] + ".png"))
(OUT / "text-fit.json").write_text(json.dumps(overflow, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"scenes": len(scenes), "estimated_overflow": len(overflow), "output": str(OUT)}, ensure_ascii=False))

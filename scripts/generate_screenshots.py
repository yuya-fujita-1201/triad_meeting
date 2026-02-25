#!/usr/bin/env python3
"""
三賢会議 (Triad Meeting) - App Store Screenshot Generator
iPhone 6.7" (1290x2796) + iPad 13" (2048x2732)
Design: Dark burgundy/gold elegant theme with ornate decorations
Supports mockup mode (draw UI) and composite mode (overlay real screenshots)
"""
from PIL import Image, ImageDraw, ImageFont
import os
import platform
import math


def find_font(candidates):
    """候補リストから最初に見つかるフォントを返す"""
    for path in candidates:
        if os.path.exists(path):
            return path
    raise FileNotFoundError(f"フォントが見つかりません: {candidates}")


# === FONT SETUP ===
if platform.system() == "Darwin":
    FONT_EN_BOLD = find_font([
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ])
    FONT_JP_BOLD = find_font([
        "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/ヒラギノ角ゴ ProN W6.otf",
        "/Library/Fonts/Arial Unicode.ttf",
    ])
    FONT_EN_REG = find_font([
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ])
    FONT_JP_REG = find_font([
        "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf",
        "/Library/Fonts/Arial Unicode.ttf",
    ])
else:
    FONT_EN_BOLD = find_font([
        "/usr/share/fonts/truetype/google-fonts/Poppins-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ])
    FONT_JP_BOLD = find_font([
        "/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Bold.ttc",
    ])
    FONT_EN_REG = find_font([
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/google-fonts/Poppins-Light.ttf",
    ])
    FONT_JP_REG = find_font([
        "/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
    ])

OUTPUT_BASE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# === COLORS (三賢会議のテーマ: バーガンディ/ゴールド/クリーム) ===
BURGUNDY_DARK = (80, 20, 40)
BURGUNDY = (120, 30, 50)
BURGUNDY_LIGHT = (160, 50, 70)
GOLD = (200, 170, 100)
GOLD_LIGHT = (220, 200, 140)
CREAM = (245, 235, 215)
CREAM_DARK = (230, 215, 190)
PARCHMENT = (250, 240, 220)
DARK_TEXT = (50, 30, 20)
MEDIUM_TEXT = (100, 70, 50)

# Screen content
SCREENS = [
    {
        "h1": "3つの視点で、",
        "h2": "迷いを終わらせる",
        "sub": "3人の賢者があなたの悩みに答える",
        "screen": "home",
    },
    {
        "h1": "3つの視点で",
        "h2": "深い議論",
        "sub": "論理・共感・直感の3人が語り合う",
        "screen": "deliberation",
    },
    {
        "h1": "明確な決議と",
        "h2": "次のアクション",
        "sub": "投票結果と具体的な行動プランを提示",
        "screen": "resolution",
    },
    {
        "h1": "すべての審議を",
        "h2": "振り返る",
        "sub": "過去の決議をいつでも確認できる",
        "screen": "history",
    },
    {
        "h1": "三賢会議",
        "h2": "",
        "sub": "3つの視点で、迷いを終わらせる",
        "screen": "branding",
    },
]


def is_cjk(ch):
    cp = ord(ch)
    return ((0x3000 <= cp <= 0x303F) or (0x3040 <= cp <= 0x309F) or
            (0x30A0 <= cp <= 0x30FF) or (0x4E00 <= cp <= 0x9FFF) or
            (0xFF00 <= cp <= 0xFFEF) or (0x2E80 <= cp <= 0x2FFF))


def measure_text(text, f_en, f_jp):
    w = 0
    for ch in text:
        f = f_jp if is_cjk(ch) else f_en
        bbox = f.getbbox(ch)
        w += bbox[2] - bbox[0]
    return w


def draw_text(draw, x, y, text, f_en, f_jp, fill=(255, 255, 255)):
    for ch in text:
        f = f_jp if is_cjk(ch) else f_en
        bbox = f.getbbox(ch)
        w = bbox[2] - bbox[0]
        draw.text((x, y), ch, font=f, fill=fill)
        x += w
    return x


def draw_centered(draw, cx, y, text, f_en, f_jp, fill=(255, 255, 255)):
    w = measure_text(text, f_en, f_jp)
    draw_text(draw, cx - w // 2, y, text, f_en, f_jp, fill)


def rrect(draw, xy, rad, fill):
    x0, y0, x1, y1 = xy
    rad = min(rad, (x1 - x0) // 2, (y1 - y0) // 2)
    if rad < 1:
        draw.rectangle([x0, y0, x1, y1], fill=fill)
        return
    draw.rectangle([x0 + rad, y0, x1 - rad, y1], fill=fill)
    draw.rectangle([x0, y0 + rad, x1, y1 - rad], fill=fill)
    draw.pieslice([x0, y0, x0 + 2 * rad, y0 + 2 * rad], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * rad, y0, x1, y0 + 2 * rad], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * rad, x0 + 2 * rad, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * rad, y1 - 2 * rad, x1, y1], 0, 90, fill=fill)


class Fonts:
    def __init__(self, h_size, sub_size, ui_size, ui_s_size):
        self.h_en = ImageFont.truetype(FONT_EN_BOLD, h_size)
        self.h_jp = ImageFont.truetype(FONT_JP_BOLD, h_size)
        self.s_en = ImageFont.truetype(FONT_EN_REG, sub_size)
        self.s_jp = ImageFont.truetype(FONT_JP_REG, sub_size)
        self.ui_en = ImageFont.truetype(FONT_EN_BOLD, ui_size)
        self.ui_jp = ImageFont.truetype(FONT_JP_BOLD, ui_size)
        self.us_en = ImageFont.truetype(FONT_EN_REG, ui_s_size)
        self.us_jp = ImageFont.truetype(FONT_JP_REG, ui_s_size)


# === BACKGROUND CREATION ===

def make_burgundy_gradient(w, h):
    """Create the signature burgundy gradient background"""
    img = Image.new("RGBA", (w, h))
    d = ImageDraw.Draw(img)
    top = BURGUNDY_DARK
    bot = (60, 15, 30)
    for y in range(h):
        r = y / h
        c = tuple(int(top[i] + (bot[i] - top[i]) * r) for i in range(3)) + (255,)
        d.line([(0, y), (w, y)], fill=c)
    return img


def draw_ornate_corners(draw, w, h, color=GOLD):
    """Draw ornate gold corner decorations"""
    s = min(w, h) // 8  # scale factor
    lw = max(2, s // 20)

    # Top-left corner
    draw.arc([20, 20, 20 + s, 20 + s], 180, 270, fill=color, width=lw)
    draw.line([(20, 20 + s // 2), (20, 20 + s)], fill=color, width=lw)
    draw.line([(20 + s // 2, 20), (20 + s, 20)], fill=color, width=lw)

    # Top-right corner
    draw.arc([w - 20 - s, 20, w - 20, 20 + s], 270, 360, fill=color, width=lw)
    draw.line([(w - 20, 20 + s // 2), (w - 20, 20 + s)], fill=color, width=lw)
    draw.line([(w - 20 - s, 20), (w - 20 - s // 2, 20)], fill=color, width=lw)

    # Bottom-left corner
    draw.arc([20, h - 20 - s, 20 + s, h - 20], 90, 180, fill=color, width=lw)
    draw.line([(20, h - 20 - s), (20, h - 20 - s // 2)], fill=color, width=lw)
    draw.line([(20 + s // 2, h - 20), (20 + s, h - 20)], fill=color, width=lw)

    # Bottom-right corner
    draw.arc([w - 20 - s, h - 20 - s, w - 20, h - 20], 0, 90, fill=color, width=lw)
    draw.line([(w - 20, h - 20 - s), (w - 20, h - 20 - s // 2)], fill=color, width=lw)
    draw.line([(w - 20 - s, h - 20), (w - 20 - s // 2, h - 20)], fill=color, width=lw)


def draw_gold_ribbon(draw, cx, y, w, h, text, f_en, f_jp):
    """Draw a gold-accented ribbon banner with text"""
    ribbon_w = int(w * 0.85)
    rx0 = cx - ribbon_w // 2
    rx1 = cx + ribbon_w // 2

    # Ribbon shape
    pts_bg = [
        (rx0, y), (rx1, y),
        (rx1, y + h),
        (rx0, y + h),
    ]
    draw.polygon(pts_bg, fill=(120, 30, 50, 200))

    # Gold borders
    draw.line([(rx0, y), (rx1, y)], fill=GOLD, width=2)
    draw.line([(rx0, y + h), (rx1, y + h)], fill=GOLD, width=2)

    # Text
    draw_centered(draw, cx, y + (h - 30) // 2, text, f_en, f_jp, GOLD_LIGHT)


# === MOCKUP CONTENT RENDERERS ===

def mock_home(d, f, cx, sx0, sx1, sy0, sy1):
    """ホーム画面: 3人の賢者が並ぶ"""
    pad = 24
    x0, x1 = sx0 + pad, sx1 - pad
    y = sy0 + 50

    # Title bar
    draw_centered(d, cx, y, "三賢会議", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 55

    # Tagline
    draw_centered(d, cx, y, "3つの視点で、迷いを終わらせる", f.us_en, f.us_jp, MEDIUM_TEXT)
    y += 50

    # Three sages
    sage_w = (x1 - x0 - 40) // 3
    sages = [
        ("論理", "論理の学者", (100, 130, 180)),
        ("共感", "共感の修道士", (180, 130, 100)),
        ("直感", "直感の預言者", (130, 160, 100)),
    ]

    for i, (name, subtitle, color) in enumerate(sages):
        sx = x0 + 10 + i * (sage_w + 20)
        # Card background
        rrect(d, (sx, y, sx + sage_w, y + 180), 14, CREAM)

        # Portrait circle
        pcx = sx + sage_w // 2
        pcy = y + 55
        pr = 35
        d.ellipse([pcx - pr, pcy - pr, pcx + pr, pcy + pr], fill=color, outline=GOLD, width=2)

        # Name
        draw_centered(d, pcx, y + 105, name, f.us_en, f.us_jp, DARK_TEXT)
        # Subtitle (smaller)
        draw_centered(d, pcx, y + 135, subtitle, f.us_en, f.us_jp, MEDIUM_TEXT)
    y += 210

    # Input area
    y += 20
    rrect(d, (x0, y, x1, y + 120), 14, (255, 255, 255))
    d.rectangle([x0, y, x1, y + 120], outline=CREAM_DARK, width=2)
    draw_text(d, x0 + 16, y + 16, "悩みを入力してください...", f.us_en, f.us_jp, (180, 160, 140))
    y += 140

    # Submit button
    y += 10
    rrect(d, (x0 + 20, y, x1 - 20, y + 55), 27, BURGUNDY)
    draw_centered(d, cx, y + 13, "三賢会議を開く", f.ui_en, f.ui_jp, GOLD_LIGHT)


def mock_deliberation(d, f, cx, sx0, sx1, sy0, sy1):
    """審議画面: 賢者たちの議論"""
    pad = 20
    x0, x1 = sx0 + pad, sx1 - pad
    y = sy0 + 50

    # Header
    draw_centered(d, cx, y, "三賢会議", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 45

    # Round indicator
    rrect(d, (x0, y, x1, y + 36), 18, BURGUNDY)
    draw_centered(d, cx, y + 6, "第 ラウンド 2 / 3", f.us_en, f.us_jp, GOLD_LIGHT)
    y += 50

    # Sage messages
    messages = [
        ("論理", (100, 130, 180), "個人の人間関係が辛い場合、転職も一つの解決策を示えます。"),
        ("共感", (180, 130, 100), "人間関係は精神的な健康に大きく影響します。まず自分の気持ちを大切にして。"),
        ("直感", (130, 160, 100), "新しい環境での変化が必要な気がします。"),
        ("論理", (100, 130, 180), "検討を整理すると、まず何が原因の人間関係の問題を確認してみましょう。"),
        ("共感", (180, 130, 100), "精神的な健康を保つためには環境を変えることも重要です。"),
    ]

    for name, color, text in messages:
        # Sage label
        rrect(d, (x0, y, x0 + 60, y + 28), 14, color)
        draw_centered(d, x0 + 30, y + 3, name, f.us_en, f.us_jp, (255, 255, 255))

        # Message bubble
        y += 32
        rrect(d, (x0, y, x1, y + 65), 12, CREAM)
        # Wrap text into the card
        draw_text(d, x0 + 12, y + 8, text[:18], f.us_en, f.us_jp, DARK_TEXT)
        draw_text(d, x0 + 12, y + 34, text[18:36] + "...", f.us_en, f.us_jp, DARK_TEXT)
        y += 78

    # Typing indicator
    draw_text(d, x0, y, "議論中...", f.us_en, f.us_jp, MEDIUM_TEXT)


def mock_resolution(d, f, cx, sx0, sx1, sy0, sy1):
    """決議書画面"""
    pad = 20
    x0, x1 = sx0 + pad, sx1 - pad
    y = sy0 + 50

    # Header
    draw_centered(d, cx, y, "決議書", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 50

    # Summary card
    rrect(d, (x0, y, x1, y + 70), 14, CREAM)
    draw_text(d, x0 + 14, y + 10, "転職を考えるのは理解できますが、", f.us_en, f.us_jp, DARK_TEXT)
    draw_text(d, x0 + 14, y + 38, "まずは現在の職場での改善策を検討", f.us_en, f.us_jp, DARK_TEXT)
    y += 85

    # Votes
    draw_text(d, x0, y, "投票", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 38
    votes = [
        ("論理", "慎重", (100, 130, 180)),
        ("共感", "共感", (180, 130, 100)),
        ("直感", "直感", (130, 160, 100)),
    ]
    vx = x0
    for name, label, color in votes:
        rrect(d, (vx, y, vx + 80, y + 36), 18, color)
        draw_centered(d, vx + 40, y + 6, name, f.us_en, f.us_jp, (255, 255, 255))
        vx += 95
    y += 52

    # Reason section
    draw_text(d, x0, y, "理由", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 35
    reasons = [
        "人間関係の改善が可能性があると考えている",
        "精神的な健康を保つためには環境変更も必要",
        "新しい環境への期待がリスクを上回る",
    ]
    for reason in reasons:
        d.ellipse([x0, y + 6, x0 + 10, y + 16], fill=BURGUNDY)
        draw_text(d, x0 + 18, y, reason[:20], f.us_en, f.us_jp, DARK_TEXT)
        y += 32

    # Next step
    y += 10
    draw_text(d, x0, y, "次の一手", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 35
    rrect(d, (x0, y, x1, y + 55), 12, CREAM)
    draw_text(d, x0 + 14, y + 14, "現在の職場での問題解決に", f.us_en, f.us_jp, DARK_TEXT)

    # Share button
    y += 75
    bw = (x1 - x0 - 20) // 2
    rrect(d, (x0, y, x0 + bw, y + 48), 24, CREAM_DARK)
    draw_centered(d, x0 + bw // 2, y + 12, "ラウンド詳細", f.us_en, f.us_jp, DARK_TEXT)
    rrect(d, (x1 - bw, y, x1, y + 48), 24, BURGUNDY)
    draw_centered(d, x1 - bw // 2, y + 12, "シェア", f.us_en, f.us_jp, GOLD_LIGHT)


def mock_history(d, f, cx, sx0, sx1, sy0, sy1):
    """履歴画面"""
    pad = 20
    x0, x1 = sx0 + pad, sx1 - pad
    y = sy0 + 50

    draw_centered(d, cx, y, "審議一覧", f.ui_en, f.ui_jp, DARK_TEXT)
    y += 55

    # History items
    items = [
        ("転職すべきか現職に残るべきか", "2026/02/25", "決議済み"),
        ("結婚のタイミングについて", "2026/02/23", "決議済み"),
        ("新しい趣味を始めるべきか", "2026/02/20", "決議済み"),
        ("引越し先の選定について", "2026/02/18", "決議済み"),
        ("副業を始めるべきか", "2026/02/15", "決議済み"),
    ]

    for title, date, status in items:
        rrect(d, (x0, y, x1, y + 90), 14, CREAM)

        # Gold left accent
        d.rectangle([x0, y + 10, x0 + 4, y + 80], fill=GOLD)

        draw_text(d, x0 + 16, y + 14, title[:16], f.us_en, f.us_jp, DARK_TEXT)
        draw_text(d, x0 + 16, y + 44, date, f.us_en, f.us_jp, MEDIUM_TEXT)

        # Status badge
        sw = 80
        rrect(d, (x1 - sw - 10, y + 48, x1 - 10, y + 72), 12, BURGUNDY)
        draw_centered(d, x1 - sw // 2 - 10, y + 50, status, f.us_en, f.us_jp, GOLD_LIGHT)

        y += 102

    # Bottom: count
    draw_centered(d, cx, y + 10, "全5件の審議", f.us_en, f.us_jp, MEDIUM_TEXT)


def mock_branding(d, f, cx, sx0, sx1, sy0, sy1):
    """ブランディング画面: 三賢者のポートレート"""
    x0, x1 = sx0, sx1
    y0, y1 = sy0, sy1
    mid_x = (x0 + x1) // 2
    mid_y = (y0 + y1) // 2

    # Parchment background
    d.rectangle([x0, y0, x1, y1], fill=PARCHMENT)

    # Aged parchment effect (subtle darker edges)
    edge = 30
    for i in range(edge):
        alpha = int(40 * (1 - i / edge))
        c = (200, 180, 150, alpha)
        d.rectangle([x0 + i, y0 + i, x1 - i, y1 - i], outline=c)

    # Three sage portraits
    portrait_r = min((x1 - x0) // 8, 60)
    gap = portrait_r * 3
    sages = [
        ((100, 130, 180), "論理"),
        ((180, 130, 100), "共感"),
        ((130, 160, 100), "直感"),
    ]
    start_x = mid_x - gap
    for i, (color, name) in enumerate(sages):
        pcx = start_x + i * gap
        pcy = mid_y - portrait_r * 2

        # Gold frame
        d.ellipse([pcx - portrait_r - 4, pcy - portrait_r - 4,
                    pcx + portrait_r + 4, pcy + portrait_r + 4], fill=GOLD)
        d.ellipse([pcx - portrait_r, pcy - portrait_r,
                    pcx + portrait_r, pcy + portrait_r], fill=color)

    # Title
    title_y = mid_y + portrait_r
    draw_centered(d, mid_x, title_y, "三賢会議", f.h_en, f.h_jp, DARK_TEXT)

    # Subtitle
    sub_y = title_y + 70
    draw_centered(d, mid_x, sub_y, "3つの視点で、迷いを終わらせる", f.s_en, f.s_jp, MEDIUM_TEXT)


MOCKUP_FNS = [mock_home, mock_deliberation, mock_resolution, mock_history, mock_branding]


def generate(idx, cw, ch, path, device="iphone", raw_screenshot=None):
    """Generate a single screenshot."""
    is_ipad = device == "ipad"
    img = make_burgundy_gradient(cw, ch)
    draw = ImageDraw.Draw(img)

    # Ornate corners
    draw_ornate_corners(draw, cw, ch, GOLD)

    if is_ipad:
        fonts = Fonts(68, 36, 34, 26)
        pw = int(cw * 0.65)
    else:
        fonts = Fonts(78, 40, 38, 28)
        pw = int(cw * 0.78)

    scr = SCREENS[idx]

    # Composite mode: determine frame height from raw screenshot aspect ratio
    if raw_screenshot and os.path.exists(raw_screenshot):
        raw_tmp = Image.open(raw_screenshot)
        raw_w, raw_h = raw_tmp.size
        raw_tmp.close()
        ins = 5
        screen_w = pw - ins * 2
        screen_h = int(screen_w * raw_h / raw_w)
        ph = screen_h + ins * 2
    else:
        ph = int(pw * 1.45)

    px = (cw - pw) // 2

    # === HEADLINE AREA ===
    hy = int(ch * 0.05)
    draw_centered(draw, cw // 2, hy, scr["h1"], fonts.h_en, fonts.h_jp, GOLD_LIGHT)

    bbox = fonts.h_jp.getbbox("あ")
    h_line = bbox[3] - bbox[1]

    if scr["h2"]:
        h2y = hy + h_line + 20
        draw_centered(draw, cw // 2, h2y, scr["h2"], fonts.h_en, fonts.h_jp, GOLD_LIGHT)
        sub_y = h2y + h_line + 25
    else:
        sub_y = hy + h_line + 35

    draw_centered(draw, cw // 2, sub_y, scr["sub"], fonts.s_en, fonts.s_jp, CREAM)

    s_bbox = fonts.s_jp.getbbox("あ")
    s_line = s_bbox[3] - s_bbox[1]

    # === DEVICE FRAME ===
    py = sub_y + s_line + 50
    if py + ph > ch - 40:
        max_ph = ch - py - 40
        if raw_screenshot and os.path.exists(raw_screenshot):
            scale = max_ph / ph
            ph = max_ph
            pw = int(pw * scale)
            px = (cw - pw) // 2
        else:
            ph = max_ph

    corner = 44 if not is_ipad else 36

    # Shadow
    sl = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(sl)
    rrect(sd, (px + 8, py + 12, px + pw + 8, py + ph + 12), corner, (0, 0, 0, 50))
    img = Image.alpha_composite(img, sl)
    draw = ImageDraw.Draw(img)

    # Device frame (dark)
    rrect(draw, (px, py, px + pw, py + ph), corner, (30, 30, 30))
    ins = 5
    sx0, sy0 = px + ins, py + ins
    sx1, sy1 = px + pw - ins, py + ph - ins

    if raw_screenshot and os.path.exists(raw_screenshot):
        # === COMPOSITE MODE ===
        raw_img = Image.open(raw_screenshot).convert("RGBA")
        screen_w = sx1 - sx0
        screen_h = sy1 - sy0
        raw_resized = raw_img.resize((screen_w, screen_h), Image.LANCZOS)
        mask = Image.new("L", (screen_w, screen_h), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, screen_w, screen_h], corner - 3, fill=255)
        img.paste(raw_resized, (sx0, sy0), mask)
        draw = ImageDraw.Draw(img)
    else:
        # === MOCKUP MODE ===
        rrect(draw, (sx0, sy0, sx1, sy1), corner - 3, (255, 255, 255))
        # Status bar
        draw.text((sx0 + 24, sy0 + 16), "9:41", font=fonts.us_en, fill=(30, 30, 30))
        scx = (sx0 + sx1) // 2
        MOCKUP_FNS[idx](draw, fonts, scx, sx0, sx1, sy0, sy1)

    # === RIBBON BANNER (bottom) ===
    if idx < 4:  # Not for branding screen
        ry = py + ph + 20
        if ry + 55 < ch - 30:
            ribbon_texts = [
                "3人の賢者があなたの悩みに答える",
                "論理・共感・直感の三つ巴",
                "投票結果と具体的な行動プラン",
                "いつでも過去の決議を振り返れる",
            ]
            draw_gold_ribbon(draw, cw // 2, ry, cw, 50, ribbon_texts[idx], fonts.s_en, fonts.s_jp)

    # Save
    out = Image.new("RGB", img.size, (255, 255, 255))
    out.paste(img, mask=img.split()[3])
    out.save(path, "PNG")
    print(f"  OK {path}")


def main():
    import argparse
    parser = argparse.ArgumentParser(description="三賢会議 App Store screenshot generator")
    parser.add_argument("--mode", choices=["mockup", "composite"], default="mockup",
                        help="mockup=UIモックアップ描画, composite=実機スクショを背景に合成")
    parser.add_argument("--raw-dir", default=None,
                        help="composite mode: iPhone実機スクショのディレクトリ")
    parser.add_argument("--raw-ipad-dir", default=None,
                        help="composite mode: iPad実機スクショのディレクトリ")
    parser.add_argument("--output", default=None,
                        help="iPhone出力先ディレクトリ")
    parser.add_argument("--output-ipad", default=None,
                        help="iPad出力先ディレクトリ")
    args = parser.parse_args()

    # Default output paths
    out_iphone = args.output or os.path.join(OUTPUT_BASE, "screenshots")
    out_ipad = args.output_ipad or os.path.join(OUTPUT_BASE, "screenshots_ipad")

    os.makedirs(out_iphone, exist_ok=True)
    os.makedirs(out_ipad, exist_ok=True)

    if args.mode == "composite":
        print("[COMPOSITE] 実機スクショを背景に合成")
        if not args.raw_dir:
            print("ERROR: --raw-dir is required for composite mode")
            return

    # iPhone 6.7" screenshots
    print("iPhone 6.7\" (1290x2796)")
    for i in range(5):
        raw = None
        if args.mode == "composite" and args.raw_dir:
            raw = os.path.join(args.raw_dir, f"screenshot_{i + 1:02d}.png")
            if not os.path.exists(raw):
                print(f"  WARN: {raw} not found, using mockup fallback")
                raw = None
        generate(i, 1290, 2796,
                 os.path.join(out_iphone, f"screenshot_{i + 1:02d}.png"),
                 "iphone", raw_screenshot=raw)

    # iPad 13" screenshots
    print("\niPad 13\" (2048x2732)")
    for i in range(5):
        raw = None
        if args.mode == "composite" and args.raw_ipad_dir:
            raw = os.path.join(args.raw_ipad_dir, f"screenshot_{i + 1:02d}.png")
            if not os.path.exists(raw):
                print(f"  WARN: {raw} not found, using mockup fallback")
                raw = None
        generate(i, 2048, 2732,
                 os.path.join(out_ipad, f"screenshot_{i + 1:02d}.png"),
                 "ipad", raw_screenshot=raw)

    print("\nDone!")


if __name__ == "__main__":
    main()

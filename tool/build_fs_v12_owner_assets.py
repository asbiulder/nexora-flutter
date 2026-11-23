#!/usr/bin/env python3
"""Build the final Finger Soccer v12 disc catalogue from the owner's supplied sheets.

Usage:
  python3 tool/build_fs_v12_owner_assets.py /path/to/sheets

The source directory must contain the team sheets, four-ball sheet and sole field from the 2026-11-23 owner upload.
The builder keeps one art per unique club/country/brand, removes only edge-connected dark sheet backgrounds, fits the
complete coin inside a common 256px transparent canvas, normalizes every ball to the same 390px visible diameter on a
418px canvas, restores the exact field, and writes a Dart team-definitions fragment on stdout.
"""
from __future__ import annotations

import math
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('/tmp/arena-coding-uploads')
ASSET_ROOT = ROOT / 'assets/games/bermuda'
OUT = ASSET_ROOT / 'discs/v12'
BALL_SOURCE = 'Picsart_26-11-24_01-03-54-987.png'
FIELD_SOURCE = 'Picsart_26-11-24_01-14-28-444.jpg'
DEDUP_REFERENCE = 'file_0000000089b0822fb0f9106a798cac30.png'

# (id, category, English, Persian). Coordinates below are row/column in each source sheet.
items: list[tuple[str, str, str, str, str, int, int, int, int]] = []

def grid(sheet: str, cols: int, rows: int, entries: list[tuple[int, int, str, str, str, str]]) -> None:
    for row, col, team_id, cat, en, fa in entries:
        items.append((team_id, cat, en, fa, sheet, cols, rows, row, col))

def rows(names: list[list[tuple[str, str, str, str] | None]]) -> list[tuple[int, int, str, str, str, str]]:
    return [(r, c, *v) for r, row in enumerate(names) for c, v in enumerate(row) if v is not None]

# High-resolution club coins first; lower-density sheets below only contribute teams not present here.
grid('file_00000000f5bc81f5bd4ba2e93d75f452.png', 5, 5, rows([
    [('club0','clubs','Real Madrid','رئال مادرید'),('club1','clubs','Barcelona','بارسلونا'),('club2','clubs','Manchester City','منچستر سیتی'),('club3','clubs','Manchester United','منچستر یونایتد'),('club4','clubs','Liverpool','لیورپول')],
    [('club5','clubs','Arsenal','آرسنال'),('club6','clubs','Chelsea','چلسی'),('club7','clubs','Bayern Munich','بایرن مونیخ'),('club8','clubs','Borussia Dortmund','دورتموند'),('club9','clubs','Paris Saint-Germain','پاری سن ژرمن')],
    [('club10','clubs','Inter Milan','اینتر میلان'),('club11','clubs','AC Milan','آ.ث. میلان'),('club12','clubs','Juventus','یوونتوس'),('club13','clubs','Atletico Madrid','اتلتیکو مادرید'),('club14','clubs','Ajax','آژاکس')],
    [('club15','clubs','Benfica','بنفیکا'),('club16','clubs','Porto','پورتو'),('club17','clubs','Boca Juniors','بوکا جونیورز'),('club18','clubs','River Plate','ریور پلاته'),('club19','clubs','Flamengo','فلامینگو')],
    [('club20','clubs','Al Nassr','النصر'),('club21','clubs','Al Hilal','الهلال'),('club22','clubs','Roma','آ.اس. رم'),None,None],
]))
grid('Picsart_26-10-29_10-54-39-519.png', 5, 5, rows([
    [None,None,None,None,None],
    [None,None,None,('club24','clubs','Tottenham Hotspur','تاتنهام'),None],
    [None,None,None,None,('club25','clubs','Olympique Marseille','مارسی')],
    [None,('club26','clubs','Napoli','ناپولی'),None,('club27','clubs','Sporting CP','اسپورتینگ'),None],
    [('club28','clubs','Sevilla','سویا'),('club29','clubs','Valencia','والنسیا'),None,('club30','clubs','PSV Eindhoven','پی‌اس‌وی'),None],
]))
grid('file_00000000a13481f4821ce70e3a799ca2.png', 8, 5, rows([
    [None]*8,
    [None]*8,
    [None,('club_lazio','clubs','Lazio','لاتزیو'),('club_atalanta','clubs','Atalanta','آتالانتا'),('club_fiorentina','clubs','Fiorentina','فیورنتینا'),None,None,None,None],
    [None,None,('club_leverkusen','clubs','Bayer Leverkusen','بایر لورکوزن'),('club_leipzig','clubs','RB Leipzig','لایپزیگ'),('club_gladbach','clubs','Borussia Mönchengladbach','مونشن‌گلادباخ'),('club_lille','clubs','Lille','لیل'),('club_westham','clubs','West Ham United','وستهام'),('club_leicester','clubs','Leicester City','لسترسیتی')],
    [('club_basel','clubs','Basel','بازل'),('club37','clubs','Celtic','سلتیک'),('club_galatasaray','clubs','Galatasaray','گالاتاسرای'),('club23','clubs','Besiktas','بشیکتاش'),('club36','clubs','Shakhtar Donetsk','شاختار دونتسک'),('club_zenit','clubs','Zenit','زنیت'),('club_salzburg','clubs','Red Bull Salzburg','سالزبورگ'),('club_dinamo','clubs','Dinamo Zagreb','دینامو زاگرب')],
]))
grid('file_000000007eec81f68d28c815cc848567.png', 6, 4, rows([
    [('club32','clubs','Persepolis','پرسپولیس'),('club33','clubs','Esteghlal','استقلال'),('club_sepahan','clubs','Sepahan','سپاهان'),('club_tractor','clubs','Tractor','تراکتور'),('club_foolad','clubs','Foolad','فولاد'),('club_zobahan','clubs','Zob Ahan','ذوب‌آهن')],
    [('club_nassaji','clubs','Nassaji Mazandaran','نساجی مازندران'),('club_sanatnaft','clubs','Sanat Naft Abadan','صنعت نفت آبادان'),('club_aluminium','clubs','Aluminium Arak','آلومینیوم اراک'),('club_mesrafsanjan','clubs','Mes Rafsanjan','مس رفسنجان'),('club_paykan','clubs','Paykan','پیکان'),('club_malavan','clubs','Malavan','ملوان')],
    [('club_golgohar','clubs','Gol Gohar Sirjan','گل‌گهر سیرجان'),('club_chadormalu','clubs','Chadormalu','چادرملو'),('club_shahin','clubs','Shahin Bushehr','شاهین بوشهر'),('club_meskerman','clubs','Mes Kerman','مس کرمان'),('club_kheybar','clubs','Kheybar Khorramabad','خیبر خرم‌آباد'),('club_arvand','clubs','Arvand Khorramshahr','اروند خرمشهر')],
    [None]*6,
]))

# National teams: use the cleaner federation coins for the shared 20, then add the 20 countries unique to the flag sheet.
grid('file_00000000559481f686c0684f28d32dfb.png', 5, 4, rows([
    [('nat0','nations','Argentina','آرژانتین'),('nat1','nations','Brazil','برزیل'),('nat3','nations','Germany','آلمان'),('nat2','nations','France','فرانسه'),('nat4','nations','Portugal','پرتغال')],
    [('nat5','nations','Spain','اسپانیا'),('nat7','nations','England','انگلیس'),('nat6','nations','Italy','ایتالیا'),('nat8','nations','Netherlands','هلند'),('nat10','nations','Uruguay','اروگوئه')],
    [('nat16','nations','Mexico','مکزیک'),('nat9','nations','Belgium','بلژیک'),('nat12','nations','Poland','لهستان'),('nat15','nations','Switzerland','سوئیس'),('nat14','nations','Croatia','کرواسی')],
    [('nat22','nations','Morocco','مراکش'),('nat21','nations','Senegal','سنگال'),('nat19','nations','South Korea','کره جنوبی'),('nat18','nations','Japan','ژاپن'),('nat17','nations','USA','آمریکا')],
]))
grid('file_000000003ac481f4ba4ab65ab773fb3b.png', 8, 5, rows([
    [None]*8,
    [None,None,('nat11','nations','Sweden','سوئد'),('nat13','nations','Denmark','دانمارک'),None,None,None,('nat_serbia','nations','Serbia','صربستان')],
    [None,None,None,('nat29','nations','Colombia','کلمبیا'),('nat_chile','nations','Chile','شیلی'),('nat_ecuador','nations','Ecuador','اکوادور'),('nat_algeria','nations','Algeria','الجزایر'),None],
    [('nat_nigeria','nations','Nigeria','نیجریه'),('nat_cameroon','nations','Cameroon','کامرون'),('nat_ghana','nations','Ghana','غنا'),None,('nat_ivorycoast','nations','Ivory Coast','ساحل عاج'),('nat23','nations','Tunisia','تونس'),('nat24','nations','Egypt','مصر'),None],
    [None,('nat20','nations','Australia','استرالیا'),('nat_newzealand','nations','New Zealand','نیوزیلند'),('nat26','nations','Iran','ایران'),('nat28','nations','Saudi Arabia','عربستان'),('nat27','nations','Qatar','قطر'),('nat_iraq','nations','Iraq','عراق'),('nat_uae','nations','UAE','امارات')],
]))

# Cars.
grid('file_00000000f1d08210bbbb907589354494.png', 5, 4, rows([
    [('car0','cars','Lamborghini','لامبورگینی'),('car1','cars','Ferrari','فراری'),('car5','cars','Porsche','پورشه'),('car3','cars','Mercedes-Benz','مرسدس بنز'),('car4','cars','BMW','بی‌ام‌و')],
    [('car7','cars','Aston Martin','استون مارتین'),('car2','cars','Rolls-Royce','رولزرویس'),('car8','cars','Bentley','بنتلی'),('car6','cars','Maserati','مازراتی'),('car9','cars','Bugatti','بوگاتی')],
    [('car12','cars','McLaren','مک‌لارن'),('car10','cars','Lexus','لکسوس'),('car13','cars','Tesla','تسلا'),('car_volvo','cars','Volvo','ولوو'),('car_landrover','cars','Land Rover','لندرور')],
    [('car_audi','cars','Audi','آئودی'),('car11','cars','Cadillac','کادیلاک'),('car_alfaromeo','cars','Alfa Romeo','آلفارومئو'),('car_pagani','cars','Pagani','پاگانی'),('car_koenigsegg','cars','Koenigsegg','کونیگزگ')],
]))

# Luxury/fashion brands.
grid('file_0000000077c881f4bc3f0f58c38927f8.png', 5, 4, rows([
    [('lux1','luxury','Chanel','شنل'),('lux0','luxury','Louis Vuitton','لویی ویتون'),('lux5','luxury','Dior','دیور'),('lux2','luxury','Gucci','گوچی'),('lux12','luxury','Yves Saint Laurent','ایو سن لوران')],
    [('lux4','luxury','Prada','پرادا'),('lux_mac','luxury','MAC','مک'),('lux_victoriassecret','luxury',"Victoria's Secret",'ویکتوریا سیکرت'),('lux_sephora','luxury','Sephora','سفورا'),('lux_esteelauder','luxury','Estée Lauder','استی لادر')],
    [('lux_lancome','luxury','Lancôme','لانکوم'),('lux_zara','luxury','Zara','زارا'),('lux_hm','luxury','H&M','اچ‌اندام'),('lux_uniqlo','luxury','Uniqlo','یونیکلو'),('lux_pandora','luxury','Pandora','پاندورا')],
    [('lux_katespade','luxury','Kate Spade','کیت اسپید'),('lux_coach','luxury','Coach','کوچ'),('lux8','luxury','Cartier','کارتیه'),('lux_tiffany','luxury','Tiffany & Co.','تیفانی'),('lux_pink','luxury','Pink','پینک')],
]))

# Sports brands.
grid('file_00000000e10081f48f8ca1ecf6748ce2.png', 5, 4, rows([
    [('spt0','sport','Nike','نایکی'),('spt1','sport','Adidas','آدیداس'),('spt2','sport','Puma','پوما'),('spt3','sport','Under Armour','آندر آرمور'),('spt5','sport','Reebok','ریباک')],
    [('spt4','sport','New Balance','نیوبالانس'),('spt7','sport','Asics','اسیکس'),('spt_mizuno','sport','Mizuno','میزونو'),('spt8','sport','Wilson','ویلسون'),('spt10','sport','Converse','کانورس')],
    [('spt6','sport','Jordan','جردن'),('spt_skechers','sport','Skechers','اسکچرز'),('spt_ea7','sport','EA7','ای‌ای سون'),('spt_northface','sport','The North Face','نورث فیس'),('spt_columbia','sport','Columbia','کلمبیا')],
    [('spt9','sport','Speedo','اسپیدو'),('spt_arena','sport','Arena','آرنا'),None,('spt_dunlop','sport','Dunlop','دانلوپ'),('spt_head','sport','Head','هد')],
]))

# Seven unique luxury and three unique sports brands from the composite sheet. Coordinates are manual because headings
# break its otherwise seven-column layout.
manual: list[tuple[str,str,str,str,str,int,int]] = [
    ('lux3','luxury','Hermès','هرمس','file_0000000089b0822fb0f9106a798cac30.png',628,576),
    ('lux6','luxury','Versace','ورساچه','file_0000000089b0822fb0f9106a798cac30.png',1156,576),
    ('lux7','luxury','Rolex','رولکس','file_0000000089b0822fb0f9106a798cac30.png',101,752),
    ('lux9','luxury','Fendi','فندی','file_0000000089b0822fb0f9106a798cac30.png',453,752),
    ('lux10','luxury','Valentino','ولنتینو','file_0000000089b0822fb0f9106a798cac30.png',628,752),
    ('lux11','luxury','Burberry','بربری','file_0000000089b0822fb0f9106a798cac30.png',804,752),
    ('lux13','luxury','Swarovski','سواروسکی','file_0000000089b0822fb0f9106a798cac30.png',1156,752),
    ('spt11','sport','Vans','ونس','file_0000000089b0822fb0f9106a798cac30.png',804,1157),
    ('spt12','sport','NBA','ان‌بی‌ای','file_0000000089b0822fb0f9106a798cac30.png',980,1157),
    ('spt13','sport','Umbro','آمبرو','file_0000000089b0822fb0f9106a798cac30.png',1156,1157),
]

# Validate ids before touching output.
all_ids = [x[0] for x in items] + [x[0] for x in manual]
assert len(all_ids) == len(set(all_ids)), 'duplicate team id'
for filename in {x[4] for x in items} | {x[4] for x in manual} | {BALL_SOURCE, FIELD_SOURCE, DEDUP_REFERENCE}:
    assert (SRC / filename).exists(), SRC / filename

if OUT.exists():
    shutil.rmtree(OUT)
OUT.mkdir(parents=True)

def finish(src: Path, crop: str, out: Path, fuzz: str = '0%') -> None:
    subprocess.run([
        'convert', str(src), '-crop', crop, '+repage', '-alpha', 'set', '-bordercolor', 'black', '-border', '1',
        '-fuzz', fuzz, '-fill', 'none', '-draw', 'matte 0,0 floodfill', '-shave', '1x1', '-trim', '+repage',
        '-resize', '246x246', '-gravity', 'center', '-background', 'none', '-extent', '256x256', '-quality', '94', str(out),
    ], check=True)

# Pixel centres measured from the dark-background gaps. They keep every rim complete even where a sheet's content is
# not centred inside mathematically equal cells (notably the bottom national row and the two 5x5 club sheets).
centres: dict[str, tuple[list[float], list[float]]] = {
    'file_00000000559481f686c0684f28d32dfb.png': ([114.5,437.5,770,1098.5,1438], [132.5,358.5,584.5,807]),
    'file_0000000077c881f4bc3f0f58c38927f8.png': ([135.5,448,786.5,1119.5,1467.5], [134.5,365.5,591,817.5]),
    'file_000000007eec81f68d28c815cc848567.png': ([123.5,397.5,672.5,946,1220,1492.5], [125,349,573,798]),
    'file_00000000a13481f4821ce70e3a799ca2.png': ([104,306.5,511.5,718.5,929,1136.5,1344.5,1550.5], [109.5,299.5,485,668.5,848.5]),
    'file_00000000e10081f48f8ca1ecf6748ce2.png': ([122,444.5,779,1110.5,1466], [130.5,357,580,802]),
    'file_00000000f1d08210bbbb907589354494.png': ([121,434.5,762,1086.5,1425.5], [129.5,356.5,580,804]),
    'file_000000003ac481f4ba4ab65ab773fb3b.png': ([110.5,300.5,487,674,861,1045,1233,1422], [134.5,316.5,499.5,683,864]),
    'file_00000000f5bc81f5bd4ba2e93d75f452.png': ([127,377,627.5,878.5,1127], [144.5,390.5,637.5,882.5,1124.5]),
    'Picsart_26-10-29_10-54-39-519.png': ([111,363.5,611,859.5,1111], [111.5,357,602,848,1086]),
}

for team_id, cat, en, fa, filename, cols, nrows, row, col in items:
    # Crop around one measured coin, not the entire grid cell: neighbouring glows cross several nominal boundaries.
    from subprocess import check_output
    dims = check_output(['identify', '-format', '%w %h', str(SRC / filename)], text=True).split()
    width, height = map(int, dims)
    cell_w, cell_h = width / cols, height / nrows
    xs, ys = centres[filename]
    cx, cy = xs[col], ys[row]
    size = round(min(cell_w, cell_h) * .96)
    x0, y0 = round(cx - size / 2), round(cy - size / 2)
    finish(SRC / filename, f'{size}x{size}+{x0}+{y0}', OUT / f'{team_id}.webp')

for team_id, cat, en, fa, filename, cx, cy in manual:
    size = 174
    finish(SRC / filename, f'{size}x{size}+{cx-size//2}+{cy-size//2}', OUT / f'{team_id}.webp', fuzz='10%')

# Four owner balls: trim each independently, then normalize the visible sphere rather than the grid cell. This fixes
# the source sheet's differing object scales while preserving aspect and gives all four the same collider contract.
ball_out = ASSET_ROOT / 'balls/v12'
if ball_out.exists():
    shutil.rmtree(ball_out)
ball_out.mkdir(parents=True)
ball_crops = {
    'nx_ball_lime': '602x624+0+0',
    'nx_ball_blue': '601x624+602+0',
    'nx_ball_purple': '602x624+0+624',
    'nx_ball_red': '601x624+602+624',
}
for slug, crop in ball_crops.items():
    subprocess.run([
        'convert', str(SRC / BALL_SOURCE), '-crop', crop, '+repage', '-channel', 'A', '-threshold', '5%', '+channel',
        '-trim', '+repage', '-resize', '390x390',
        '-gravity', 'center', '-background', 'none', '-extent', '418x418', '-quality', '94', str(ball_out / f'{slug}.webp'),
    ], check=True)

# The match uses the supplied field byte-for-byte; only its small shop thumbnail is derived.
field_out = ASSET_ROOT / 'fields/nx_sockerbox_owner.jpg'
field_out.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(SRC / FIELD_SOURCE, field_out)
thumb_out = ASSET_ROOT / 'thumbs/nx_sockerbox_owner.webp'
thumb_out.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([
    'convert', str(field_out), '-resize', '240x380', '-quality', '90', str(thumb_out),
], check=True)

# Stable, plausible play stats. Elite football nations/clubs get a small explicit bump; visual-brand categories are
# consistently premium. Stats affect shot power/accuracy, never collision dimensions.
elite = {'Real Madrid','Barcelona','Manchester City','Bayern Munich','Argentina','Brazil','France','Germany','Spain'}
def stats(cat: str, en: str) -> tuple[int,int]:
    if en in elite:
        return (10, 10 if en in {'Real Madrid','Argentina','France'} else 9)
    floor = 8 if cat in {'cars','luxury','sport'} else 7
    score = sum(ord(c) for c in en)
    return floor + score % (11-floor), floor + (score // 7) % (11-floor)

records = [(x[0],x[1],x[2],x[3]) for x in items] + [(x[0],x[1],x[2],x[3]) for x in manual]
cat_order = {'clubs':0,'nations':1,'cars':2,'luxury':3,'sport':4}
records.sort(key=lambda x: (cat_order[x[1]], x[2].casefold(), x[0]))
for team_id, cat, en, fa in records:
    p, a = stats(cat, en)
    if team_id in {'club32','club33'}: p, a = 9, 8
    if team_id == 'nat26': p, a = 8, 8
    print(f"  BmTeamDef('{team_id}', '{cat}', {en!r}, {fa!r}, 'discs/v12/{team_id}', {p}, {a}),")
print(f'// generated {len(records)} unique owner teams', file=sys.stderr)

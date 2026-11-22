// GENERATED from BERMUDA_NXG www/js/game.js — do not retune. Values are copied 1:1.
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui' show Color;

class BmField {
  const BmField(this.id, this.name, this.w0, this.h0, this.l0, this.r0, this.t0, this.b0, this.cs0, this.g0, this.gs,
      {this.rc = 70, this.gh0 = 0, this.gr0 = 0, this.gd0 = 0, this.asset, this.score, this.scoreRight = const Color(0xFFFF3B30)});
  final String id, name, gs;
  /// Raw image-space values (before FS scale). l0/r0/t0/b0 = the drawn boundary the ball bounces on (measured on the
  /// art: the touch line, or the barrier's inner edge where the art has no line in front of it).
  final int w0, h0, l0, r0, t0, b0, cs0, g0;
  /// Corner radius of the drawn boundary, in world units (measured per field on the art).
  final double rc;
  /// Fields whose art has the goals built in (gs == 'none'): post-centre half width, post radius and net depth,
  /// image px measured on the art. Unused for fields that draw a separate goal sprite.
  final double gh0, gr0, gd0;
  /// Field image (defaults to `assets/games/bermuda/fields/<id>.webp`).
  final String? asset;
  /// v9: the score displays drawn into the art (null = none). The whole art is then fitted to the screen and the live
  /// score is drawn on these displays instead of a HUD scoreboard.
  final BmScoreDisplay? score;
  /// Colour of the right-hand display (the left one is always blue, the bottom / home side).
  final Color scoreRight;
  bool get fullArt => score != null;
  bool get builtInGoals => gs == 'none';
}

/// v9: geometry of the two side score displays drawn into a pitch art (image px of the art, [artW] wide). Each display
/// stacks two seven-segment digit cells: tens on top, ones below. The left (blue) display shows the bottom / home
/// side, the right one the other side.
class BmScoreDisplay {
  const BmScoreDisplay(this.artW, this.leftCx, this.rightCx, this.tensCy, this.onesCy, this.digitW, this.digitH);
  final double artW, leftCx, rightCx, tensCy, onesCy, digitW, digitH;
}

/// The displays are at the same place on all three v9 arts (measured by tool/build_fs_v9_assets.py, DIGIT_BOXES).
const BmScoreDisplay kBmV9Score = BmScoreDisplay(941, 42.5, 897.5, 725, 786, 30, 40);
const Color kBmScoreLeft = Color(0xFF2F86FF);
/// Image px -> raw field units for the v9 arts.
const double kBmV9ArtScale = .85;

const List<BmField> kBmFieldsRaw = <BmField>[
  // v9 (owner request 2026-11-22): the ONLY pitches are the owner's three Sockerbox arts (941 x 1672, goals, nets and
  // the two side score displays drawn in). Every value is measured on the art by tool/build_fs_v9_assets.py, in image
  // px times kBmV9ArtScale (.85, so the playing width is ~880 world units like the reference proportions): the rails
  // are the inner edge of the coloured frame line, the posts are the white tubes where they cross the goal line
  // (centre 132.5 px either side of the centre line, tube radius 6.5 px) and the net depth is the shallower of the two
  // drawn goals (the engine keeps both goals the same depth so mirrored online phones stay deterministic).
  BmField('nx_neon_arena', 'Neon Arena', 800, 1421, 71, 727, 90, 1286, 688, 0, 'none',
      rc: 22, gh0: 112.62, gr0: 5.52, gd0: 85.00, score: kBmV9Score, scoreRight: Color(0xFFFF3B30)),
  BmField('nx_gold_checker', 'Gold Checker', 800, 1421, 70, 730, 88, 1329, 708, 0, 'none',
      rc: 22, gh0: 112.62, gr0: 5.52, gd0: 83.30, score: kBmV9Score, scoreRight: Color(0xFFFFA21F)),
  BmField('nx_gold_stripes', 'Gold Stripes', 800, 1421, 70, 730, 88, 1329, 708, 0, 'none',
      rc: 22, gh0: 112.62, gr0: 5.52, gd0: 83.30, score: kBmV9Score, scoreRight: Color(0xFFFFA21F)),
];

/// Ids of pitches removed from the game (v7 and v9). Kept only so tests can check they never come back.
const List<String> kBmRemovedFieldIds = <String>[
  'neon_cup', 'street_cage', 'sockerbox', 'gold_leather', 'neon_grass', 'royal_gold',
  // v9: every older pitch
  'nexora_green', 'forest', 'ice', 'ocean', 'street', 'streetarena', 'lava', 'stadium', 'checker', 'futsal', 'arena',
  'arena2', 'desert', 'grove', 'pool', 'neon', 'royal', 'mahogany', 'leather', 'aqua', 'asphalt', 'court', 'cyberbox',
  'realmadrid', 'psg', 'acmilan', 'barcelona', 'persepolis', 'esteghlal', 'mancity',
];

/// A saved / synced pitch index -> a valid one: anything missing or out of range (e.g. a removed v6 pitch) is the
/// default pitch 0 (v9: Neon Arena).
int bmFieldIndex(int? i) => (i == null || i < 0 || i >= kBmFieldsRaw.length) ? 0 : i;

/// Goal art measured on each sprite (alpha): [width, height, left post centre, right post centre, post half-width,
/// inner edge of the back bar, bottom of the posts] - x values are fractions of the width, y values of the height.
/// The engine builds the posts, the side nets and the back net from these numbers, so the drawn goal is the collider.
const Map<String, List<double>> kBmGS = <String, List<double>>{
  // The only goal art (owner asset goalpost_139462.png: white tubular frame, hexagonal net, front view).
  'white': <double>[840, 307, 0.0470, 0.9548, 0.0167, 0.0945, 0.9967],
};

/// v9 (owner request 2026-11-22): the teams are the owner's two badge sheets (48 round NX badges, cut one per disc by
/// tool/build_fs_v9_assets.py). Categories: cars, sports brands and the NX house badges.
const List<List<Object>> kBmCats = <List<Object>>[
  <Object>['car', 'Cars', 'خودرو'],
  <Object>['sport', 'Sport', 'ورزشی'],
  <Object>['nx', 'NX', 'انیکس'],
];

/// One selectable piece set. [power] scales the shot impulse, [accuracy] narrows the aim spread (both 1..10).
class BmTeamDef {
  const BmTeamDef(this.id, this.cat, this.name, this.art, this.power, this.accuracy);
  final String id, cat, name;
  /// Asset path relative to assets/games/bermuda/ (without .webp).
  final String art;
  final int power, accuracy;
}

/// The ids are the existing shop catalogue ids (club0..club39, nat20..nat27) on purpose: the gem shop's server
/// catalogue (nx_catalog on the auth project) prices and sells items by these ids, and its free teams (club32,
/// club33, nat26) stay free - here they are the NX house badges NX Core, NX Pulse and NX Inferno. See DECISIONS D15.
const List<BmTeamDef> kBmTeamDefs = <BmTeamDef>[
  BmTeamDef('club0', 'car', 'BMW', 'discs/v9/bmw', 9, 9),
  BmTeamDef('club1', 'car', 'Mercedes-Benz', 'discs/v9/mercedes', 9, 9),
  BmTeamDef('club2', 'car', 'Audi', 'discs/v9/audi', 8, 9),
  BmTeamDef('club3', 'car', 'Bugatti', 'discs/v9/bugatti', 10, 9),
  BmTeamDef('club4', 'car', 'Ferrari', 'discs/v9/ferrari', 10, 9),
  BmTeamDef('club5', 'car', 'Porsche', 'discs/v9/porsche', 9, 10),
  BmTeamDef('club6', 'car', 'McLaren', 'discs/v9/mclaren', 10, 8),
  BmTeamDef('club7', 'car', 'Aston Martin', 'discs/v9/aston_martin', 8, 9),
  BmTeamDef('club8', 'car', 'Volkswagen', 'discs/v9/volkswagen', 7, 8),
  BmTeamDef('club9', 'car', 'Lamborghini', 'discs/v9/lamborghini', 10, 8),
  BmTeamDef('club10', 'car', 'Toyota', 'discs/v9/toyota', 7, 9),
  BmTeamDef('club11', 'car', 'Nissan', 'discs/v9/nissan', 7, 8),
  BmTeamDef('club12', 'car', 'BMW II', 'discs/v9/bmw_ii', 9, 9),
  BmTeamDef('club13', 'car', 'Mercedes-Benz II', 'discs/v9/mercedes_ii', 9, 9),
  BmTeamDef('club14', 'car', 'Audi II', 'discs/v9/audi_ii', 8, 9),
  BmTeamDef('club15', 'car', 'Toyota II', 'discs/v9/toyota_ii', 7, 9),
  BmTeamDef('club16', 'car', 'Ferrari II', 'discs/v9/ferrari_ii', 10, 9),
  BmTeamDef('club17', 'car', 'Porsche II', 'discs/v9/porsche_ii', 9, 10),
  BmTeamDef('club18', 'car', 'Honda', 'discs/v9/honda', 7, 8),
  BmTeamDef('club19', 'car', 'Ford', 'discs/v9/ford', 8, 7),
  BmTeamDef('club20', 'car', 'Volkswagen II', 'discs/v9/volkswagen_ii', 7, 8),
  BmTeamDef('club21', 'car', 'Lamborghini II', 'discs/v9/lamborghini_ii', 10, 8),
  BmTeamDef('club22', 'car', 'Chevrolet', 'discs/v9/chevrolet', 8, 7),
  BmTeamDef('club23', 'car', 'Nissan II', 'discs/v9/nissan_ii', 7, 8),
  BmTeamDef('club24', 'sport', 'Nike', 'discs/v9/nike', 9, 8),
  BmTeamDef('club25', 'sport', 'Adidas', 'discs/v9/adidas', 8, 9),
  BmTeamDef('club26', 'sport', 'Puma', 'discs/v9/puma', 8, 8),
  BmTeamDef('club27', 'sport', 'Under Armour', 'discs/v9/under_armour', 8, 7),
  BmTeamDef('club28', 'sport', 'Reebok', 'discs/v9/reebok', 7, 7),
  BmTeamDef('club29', 'sport', 'New Balance', 'discs/v9/new_balance', 7, 8),
  BmTeamDef('club30', 'sport', 'Nike II', 'discs/v9/nike_ii', 9, 8),
  BmTeamDef('club31', 'sport', 'Adidas II', 'discs/v9/adidas_ii', 8, 9),
  BmTeamDef('nat20', 'sport', 'Puma II', 'discs/v9/puma_ii', 8, 8),
  BmTeamDef('nat21', 'sport', 'Under Armour II', 'discs/v9/under_armour_ii', 8, 7),
  BmTeamDef('nat22', 'sport', 'New Balance II', 'discs/v9/new_balance_ii', 7, 8),
  BmTeamDef('nat23', 'sport', 'Reebok II', 'discs/v9/reebok_ii', 7, 7),
  BmTeamDef('club32', 'nx', 'NX Core', 'discs/v9/nx_core', 6, 6),
  BmTeamDef('club33', 'nx', 'NX Pulse', 'discs/v9/nx_pulse', 6, 6),
  BmTeamDef('club34', 'nx', 'NX Prism', 'discs/v9/nx_prism', 8, 8),
  BmTeamDef('club35', 'nx', 'NX Infinity', 'discs/v9/nx_infinity', 9, 9),
  BmTeamDef('club36', 'nx', 'NX Nova', 'discs/v9/nx_nova', 9, 8),
  BmTeamDef('club37', 'nx', 'NX Summit', 'discs/v9/nx_summit', 8, 9),
  BmTeamDef('club38', 'nx', 'NX Circuit', 'discs/v9/nx_circuit', 8, 8),
  BmTeamDef('club39', 'nx', 'NX Holo', 'discs/v9/nx_holo', 9, 9),
  BmTeamDef('nat24', 'nx', 'NX Dragon', 'discs/v9/nx_dragon', 10, 9),
  BmTeamDef('nat25', 'nx', 'NX Galaxy', 'discs/v9/nx_galaxy', 9, 10),
  BmTeamDef('nat26', 'nx', 'NX Inferno', 'discs/v9/nx_inferno', 6, 6),
  BmTeamDef('nat27', 'nx', 'NX Frost', 'discs/v9/nx_frost', 10, 10),
];

class BmTrail {
  const BmTrail(this.k, this.c);
  final String k;
  final List<int> c;
}

const List<BmTrail> kBmTR = <BmTrail>[
  BmTrail('bolt', <int>[0xFF19B4FF,0xFF8FE6FF,0xFFFFFFFF]),
  BmTrail('prism', <int>[0xFFFF7BD5,0xFF7BD7FF,0xFFFFFFFF]),
  BmTrail('wave', <int>[0xFF2FE0D0,0xFF9FF7EF,0xFFFFFFFF]),
  BmTrail('star', <int>[0xFF5CB6FF,0xFFBFE3FF,0xFFFFFFFF]),
  BmTrail('smoke', <int>[0xFFE8ECF2,0xFF9AA3B0,0xFFFFFFFF]),
  BmTrail('rainbow', <int>[0xFFFF5B5B,0xFFFFD23A,0xFF5BFF8A,0xFF5BD0FF,0xFFC05BFF]),
  BmTrail('neon', <int>[0xFF4DFF2A,0xFFB6FF9A,0xFFFFFFFF]),
  BmTrail('yin', <int>[0xFFFFFFFF,0xFF9B5CFF,0xFF000000]),
  BmTrail('fire', <int>[0xFFFF8A1F,0xFFFFD24A,0xFFFFF3C4]),
  BmTrail('blade', <int>[0xFFFF2B3A,0xFFFF8A92,0xFFFFFFFF]),
  BmTrail('ghost', <int>[0xFFDBE7FF,0xFF8FB0FF,0xFFFFFFFF]),
  BmTrail('ember', <int>[0xFFFF6A1F,0xFFFFB347,0xFFFFF0C8]),
  BmTrail('plasma', <int>[0xFF2F8BFF,0xFF7FC6FF,0xFFFFFFFF]),
  BmTrail('ghost', <int>[0xFFD9915B,0xFFF2C9A0,0xFFFFF4E6]),
  BmTrail('star', <int>[0xFF2F7BFF,0xFF8FD0FF,0xFFFFFFFF]),
  BmTrail('wave', <int>[0xFF9B5CFF,0xFFE0B8FF,0xFFFFFFFF]),
  BmTrail('fire', <int>[0xFFE0A82E,0xFFFFE08A,0xFFFFF7D6]),
  BmTrail('bolt', <int>[0xFF2F6BFF,0xFF7FB4FF,0xFFFFFFFF]),
  BmTrail('neon', <int>[0xFF2F8BFF,0xFFE8B84A,0xFFFFFFFF]),
  BmTrail('prism', <int>[0xFF1FD6A0,0xFF3B9BFF,0xFFFFFFFF]),
  BmTrail('blade', <int>[0xFFFF2B3A,0xFFFF8A92,0xFFFFFFFF]),
  BmTrail('plasma', <int>[0xFF18D8C0,0xFF9FF5E6,0xFFFFFFFF]),
  BmTrail('ember', <int>[0xFF2F5BFF,0xFFFFC83A,0xFFFFF3C4]),
  BmTrail('yin', <int>[0xFFFFFFFF,0xFFE0A82E,0xFF000000]),
  BmTrail('smoke', <int>[0xFFFF4A4A,0xFF9AA3B0,0xFFFFFFFF]),
  BmTrail('star', <int>[0xFFE0A82E,0xFFFFF0B0,0xFFFFFFFF]),
  BmTrail('plasma', <int>[0xFF2F8BFF,0xFFC0C8D8,0xFFFFFFFF]),
  BmTrail('ghost', <int>[0xFF9B5CFF,0xFFFFFFFF,0xFFFFFFFF]),
  BmTrail('neon', <int>[0xFF4DFF2A,0xFFC0C8D8,0xFFFFFFFF]),
  BmTrail('blade', <int>[0xFFE8B84A,0xFF2F6BFF,0xFFFFFFFF]),
  BmTrail('fire', <int>[0xFFFF2B3A,0xFFFF8A92,0xFFFFFFFF]),
  BmTrail('ember', <int>[0xFFFF8A1F,0xFFFFD24A,0xFFFFFFFF]),
  BmTrail('wave', <int>[0xFF3B9BFF,0xFF2FE08A,0xFFFFFFFF]),
  BmTrail('prism', <int>[0xFFFF4A7A,0xFF9B5CFF,0xFFFFFFFF]),
  BmTrail('bolt', <int>[0xFF2F6BFF,0xFFFFFFFF,0xFFFFFFFF]),
  BmTrail('star', <int>[0xFFFFD56B,0xFFFFFFFF,0xFFFFFFFF]),
];

const List<String> kBmTRN = <String>["Bolt", "Prism", "Wave", "Starlight", "Smoke", "Rainbow", "Neon", "Yin", "Fire", "Blade", "Ghost", "Ember", "Plasma", "Copper Ghost", "Stardust", "Twilight", "Gold Flame", "Thunder", "Cobalt Neon", "Aurora", "Crimson Blade", "Teal Storm", "Royal Ember", "Gold Yin", "Red Smoke", "Gilded Star", "Noir Chrome", "Violet Strike", "Emerald Edge", "Royal Blue Gold", "Crimson Noir", "Blaze Orange", "Aqua Wave", "Sunset Pro", "Elite Cobalt", "Crown Luxury"];

/// v9 (owner request 2026-11-22): the match balls are the owner's ball art only (18 balls from four sheets, trimmed to
/// their circle by tool/build_fs_v9_assets.py into `assets/games/bermuda/balls/v9/<slug>.webp`). Every ball is a flat
/// art that fills its square; the 3D ball renderer (BmBallRenderer) rolls it with the ball's real motion.
const List<String> kBmBallN = <String>['NX Yellow', 'NX Green', 'NX Blue', 'NX Pink', 'NX Ice', 'Pro Lime', 'Pro Green', 'Pro Blue', 'Pro Magenta', 'Classic Noir', 'Classic Plum', 'Classic', 'Hex Lime', 'Hex Violet', 'Hex Teal', 'Frost', 'Pearl', 'Street'];
const List<String> kBmBallFa = <String>['NX زرد', 'NX سبز', 'NX آبی', 'NX صورتی', 'NX یخی', 'پرو لیمویی', 'پرو سبز', 'پرو آبی', 'پرو سرخابی', 'کلاسیک مشکی', 'کلاسیک آلویی', 'کلاسیک', 'شش‌ضلعی لیمویی', 'شش‌ضلعی بنفش', 'شش‌ضلعی فیروزه‌ای', 'یخ‌زده', 'مروارید', 'خیابانی'];
const List<String> kBmBallSlug = <String>['nx_yellow', 'nx_green', 'nx_blue', 'nx_pink', 'nx_ice', 'pro_lime', 'pro_green', 'pro_blue', 'pro_magenta', 'classic_noir', 'classic_plum', 'classic', 'hex_lime', 'hex_violet', 'hex_teal', 'frost', 'pearl', 'street'];
const int kBmDefaultBall = 0;

/// Preference key of the player's match ball. v9 uses a new key: every saved index named an old ball.
const String kBmBallPref = 'bm.ball.v9';

/// A saved / synced ball index -> a valid one (missing or unknown = the default ball).
int bmBallIndex(int? i) => (i == null || i < 0 || i >= kBmBallN.length) ? kBmDefaultBall : i;

/// The art of ball [i] (also its picker / shop thumbnail).
String bmBallArt(int i) => 'assets/games/bermuda/balls/v9/${kBmBallSlug[bmBallIndex(i)]}.webp';
String bmBallThumb(int i) => bmBallArt(i);

class BmAnimBall {
  const BmAnimBall(this.sheet, this.frames, this.frameMs, this.thumb, {this.gifTimed = false});
  final String sheet;
  final int frames;
  final int frameMs;
  final String thumb;
  /// GIF balls: frames in the GIF's order at exactly [frameMs] each while the ball moves.
  final bool gifTimed;

  /// Frame shown after [ms] of playback (GIF order, [frameMs] each, looping).
  int frameAt(double ms) => (ms / frameMs).floor() % frames;
}

/// Animated sprite-sheet balls. v9: none (every ball is rolled by the 3D renderer); the painter keeps the sheet path
/// so a future animated ball only needs an entry here.
const Map<int, BmAnimBall> kBmAnimBalls = <int, BmAnimBall>{};

/// Art fills (tool/build_fs_v9_assets.py): disc rim radius / half sprite size, ball radius / half frame size.
/// The painter draws every sprite so the rim lands exactly on the physics radius.
const double kBmDiscArtFill = 120 / 128;
const double kBmBallArtFill = 76 / 80;

class BmFa {
  const BmFa(this.k, this.c, this.g);
  final int k;
  final List<int> c;
  final double g;
}

const Map<String, BmFa> kBmFA = <String, BmFa>{
  // v9 pitches: goal firework colours taken from each art's frame / display colours.
  'nx_neon_arena': BmFa(5, <int>[0xFFFF3B30, 0xFF2F86FF, 0xFFFFFFFF], 0),
  'nx_gold_checker': BmFa(1, <int>[0xFFFFC21F, 0xFFFFFFFF, 0xFF2F86FF], 0),
  'nx_gold_stripes': BmFa(1, <int>[0xFFFFC21F, 0xFFFFFFFF, 0xFFFF8A1F], 0),
  // fallback used by the engine for any id without its own entry
  'stadium': BmFa(1, <int>[0xFFFFD86B, 0xFFFFFFFF, 0xFFFFE9A8], 0),
};

// GENERATED from BERMUDA_NXG www/js/game.js — do not retune. Values are copied 1:1.
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui' show Color;

class BmField {
  const BmField(this.id, this.name, this.w0, this.h0, this.l0, this.r0, this.t0, this.b0, this.cs0, this.g0, this.gs,
      {this.rc = 70,
      this.gh0 = 0,
      this.gr0 = 0,
      this.gd0 = 0,
      this.asset,
      this.score,
      this.faName = '',
      this.scoreLeft = kBmScoreLeft,
      this.scoreRight = const Color(0xFFFF3B30)});
  final String id, name, gs;
  /// Persian name (shown when the UI is in Persian; empty = use [name]).
  final String faName;
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
  /// Colours of the live digits on the left-hand (bottom / home side) and right-hand displays, measured on the art's
  /// printed digits.
  final Color scoreLeft, scoreRight;
  bool get fullArt => score != null;
  bool get builtInGoals => gs == 'none';
}

/// Geometry of the two side score displays drawn into a pitch art (image px of the art, [artW] wide). Each display
/// stacks two seven-segment digit cells: tens on top, ones below. The left display shows the bottom / home side, the
/// right one the other side. The v12 values are measured on the sole supplied Sockerbox art.
class BmScoreDisplay {
  const BmScoreDisplay(this.artW, this.leftCx, this.rightCx, this.tensCy, this.onesCy, this.digitW, this.digitH);
  final double artW, leftCx, rightCx, tensCy, onesCy, digitW, digitH;
}

/// Default colour of the left (bottom / home side) display's digits.
const Color kBmScoreLeft = Color(0xFF2F86FF);

const List<BmField> kBmFieldsRaw = <BmField>[
  // v12: this is the only match pitch. Keep the owner's 1992 x 3155 JPEG at full resolution; the logical geometry
  // maps the visible inner rails and built-in goals to the existing finger-soccer physics coordinate system.
  BmField(
    'nx_sockerbox_owner',
    'NX Sockerbox',
    810,
    1283,
    76,
    734,
    72,
    1175,
    622,
    0,
    'none',
    rc: 10,
    gh0: 116,
    gr0: 5,
    gd0: 72,
    asset: 'assets/games/bermuda/fields/nx_sockerbox_owner.jpg',
    score: BmScoreDisplay(1992, 123, 1869, 1330, 1446, 52, 64),
    faName: 'زمین ساکرباکس NX',
  ),
];

/// Ids of pitches removed from the game. Kept only so regressions can prove that the one-field v12 catalogue never
/// silently brings an older pitch back.
const List<String> kBmRemovedFieldIds = <String>[
  'neon_cup', 'street_cage', 'sockerbox', 'gold_leather', 'neon_grass', 'royal_gold',
  'nexora_green', 'forest', 'ice', 'ocean', 'street', 'streetarena', 'lava', 'stadium', 'checker', 'futsal', 'arena',
  'arena2', 'desert', 'grove', 'pool', 'neon', 'royal', 'mahogany', 'leather', 'aqua', 'asphalt', 'court', 'cyberbox',
  'realmadrid', 'psg', 'acmilan', 'barcelona', 'persepolis', 'esteghlal', 'mancity',
  'nx_neon_arena', 'nx_gold_checker', 'nx_gold_stripes',
  'nx_checker_silver', 'nx_rings_green', 'nx_street', 'nx_neon_blue', 'nx_royal_purple',
  'nx_green_plain', 'nx_rings_green_new', 'nx_checker_green', 'nx_stripes_green', 'nx_stripes_teal',
  'nx_ember_street', 'nx_black_sockerbox',
];

/// A saved / synced pitch index -> the sole v12 pitch.
int bmFieldIndex(int? i) => 0;

/// New key prevents an index from any earlier multi-pitch catalogue being interpreted as the owner pitch.
const String kBmFieldPref = 'bm.field.v12';

/// Pitch [i]'s name in the UI language (Persian when [fa] and the pitch has one).
String bmFieldName(int i, bool fa) {
  final BmField f = kBmFieldsRaw[bmFieldIndex(i)];
  return fa && f.faName.isNotEmpty ? f.faName : f.name;
}

/// Goal art measured on each sprite (alpha): [width, height, left post centre, right post centre, post half-width,
/// inner edge of the back bar, bottom of the posts] - x values are fractions of the width, y values of the height.
/// The engine builds the posts, the side nets and the back net from these numbers, so the drawn goal is the collider.
const Map<String, List<double>> kBmGS = <String, List<double>>{
  // The only goal art (owner asset goalpost_139462.png: white tubular frame, hexagonal net, front view).
  'white': <double>[840, 307, 0.0470, 0.9548, 0.0167, 0.0945, 0.9967],
};

/// v12 categories for the owner's replacement catalogue. Alternate artwork is deduplicated by identity, while every
/// unique supplied club, national team, car, luxury brand and sports brand is retained.
const String kBmStarterTeamId = 'club32';
const String kBmStarterOpponentId = 'club33';

const List<List<Object>> kBmCats = <List<Object>>[
  <Object>['clubs', 'Clubs', 'باشگاهی'],
  <Object>['nations', 'Nations', 'ملی'],
  <Object>['cars', 'Cars', 'خودرو'],
  <Object>['luxury', 'Luxury', 'لوکس'],
  <Object>['sport', 'Sport', 'ورزشی'],
];

/// One selectable piece set. [power] scales the shot impulse, [accuracy] narrows the aim spread (both 1..10).
class BmTeamDef {
  const BmTeamDef(this.id, this.cat, this.name, this.faName, this.art, this.power, this.accuracy);
  final String id, cat, name;
  /// Persian name (shown when the UI is in Persian; the English name above is the canonical one).
  final String faName;
  /// Asset path relative to assets/games/bermuda/ (without .webp).
  final String art;
  final int power, accuracy;
}

/// Final v12 owner catalogue. Every built-in disc comes from the supplied sheets, is cropped to one complete coin,
/// and belongs to exactly one visible category. The custom photo team remains a separate shop entitlement.
const List<BmTeamDef> kBmTeamDefs = <BmTeamDef>[
  BmTeamDef('club11', 'clubs', 'AC Milan', 'آ.ث. میلان', 'discs/v12/club11', 8, 9),
  BmTeamDef('club14', 'clubs', 'Ajax', 'آژاکس', 'discs/v12/club14', 7, 10),
  BmTeamDef('club21', 'clubs', 'Al Hilal', 'الهلال', 'discs/v12/club21', 10, 10),
  BmTeamDef('club20', 'clubs', 'Al Nassr', 'النصر', 'discs/v12/club20', 7, 10),
  BmTeamDef('club_aluminium', 'clubs', 'Aluminium Arak', 'آلومینیوم اراک', 'discs/v12/club_aluminium', 7, 9),
  BmTeamDef('club5', 'clubs', 'Arsenal', 'آرسنال', 'discs/v12/club5', 9, 8),
  BmTeamDef('club_arvand', 'clubs', 'Arvand Khorramshahr', 'اروند خرمشهر', 'discs/v12/club_arvand', 9, 9),
  BmTeamDef('club_atalanta', 'clubs', 'Atalanta', 'آتالانتا', 'discs/v12/club_atalanta', 9, 10),
  BmTeamDef('club13', 'clubs', 'Atletico Madrid', 'اتلتیکو مادرید', 'discs/v12/club13', 9, 9),
  BmTeamDef('club1', 'clubs', 'Barcelona', 'بارسلونا', 'discs/v12/club1', 10, 9),
  BmTeamDef('club_basel', 'clubs', 'Basel', 'بازل', 'discs/v12/club_basel', 10, 8),
  BmTeamDef('club_leverkusen', 'clubs', 'Bayer Leverkusen', 'بایر لورکوزن', 'discs/v12/club_leverkusen', 10, 10),
  BmTeamDef('club7', 'clubs', 'Bayern Munich', 'بایرن مونیخ', 'discs/v12/club7', 10, 9),
  BmTeamDef('club15', 'clubs', 'Benfica', 'بنفیکا', 'discs/v12/club15', 7, 8),
  BmTeamDef('club23', 'clubs', 'Besiktas', 'بشیکتاش', 'discs/v12/club23', 9, 8),
  BmTeamDef('club17', 'clubs', 'Boca Juniors', 'بوکا جونیورز', 'discs/v12/club17', 10, 7),
  BmTeamDef('club8', 'clubs', 'Borussia Dortmund', 'دورتموند', 'discs/v12/club8', 8, 8),
  BmTeamDef('club_gladbach', 'clubs', 'Borussia Mönchengladbach', 'مونشن\u200cگلادباخ', 'discs/v12/club_gladbach', 8, 7),
  BmTeamDef('club37', 'clubs', 'Celtic', 'سلتیک', 'discs/v12/club37', 7, 8),
  BmTeamDef('club_chadormalu', 'clubs', 'Chadormalu', 'چادرملو', 'discs/v12/club_chadormalu', 7, 9),
  BmTeamDef('club6', 'clubs', 'Chelsea', 'چلسی', 'discs/v12/club6', 8, 10),
  BmTeamDef('club_dinamo', 'clubs', 'Dinamo Zagreb', 'دینامو زاگرب', 'discs/v12/club_dinamo', 10, 7),
  BmTeamDef('club33', 'clubs', 'Esteghlal', 'استقلال', 'discs/v12/club33', 9, 8),
  BmTeamDef('club_fiorentina', 'clubs', 'Fiorentina', 'فیورنتینا', 'discs/v12/club_fiorentina', 10, 7),
  BmTeamDef('club19', 'clubs', 'Flamengo', 'فلامینگو', 'discs/v12/club19', 8, 10),
  BmTeamDef('club_foolad', 'clubs', 'Foolad', 'فولاد', 'discs/v12/club_foolad', 8, 8),
  BmTeamDef('club_galatasaray', 'clubs', 'Galatasaray', 'گالاتاسرای', 'discs/v12/club_galatasaray', 9, 8),
  BmTeamDef('club_golgohar', 'clubs', 'Gol Gohar Sirjan', 'گل\u200cگهر سیرجان', 'discs/v12/club_golgohar', 9, 8),
  BmTeamDef('club10', 'clubs', 'Inter Milan', 'اینتر میلان', 'discs/v12/club10', 10, 8),
  BmTeamDef('club12', 'clubs', 'Juventus', 'یوونتوس', 'discs/v12/club12', 7, 7),
  BmTeamDef('club_kheybar', 'clubs', 'Kheybar Khorramabad', 'خیبر خرم\u200cآباد', 'discs/v12/club_kheybar', 9, 8),
  BmTeamDef('club_lazio', 'clubs', 'Lazio', 'لاتزیو', 'discs/v12/club_lazio', 10, 8),
  BmTeamDef('club_leicester', 'clubs', 'Leicester City', 'لسترسیتی', 'discs/v12/club_leicester', 8, 10),
  BmTeamDef('club_lille', 'clubs', 'Lille', 'لیل', 'discs/v12/club_lille', 9, 10),
  BmTeamDef('club4', 'clubs', 'Liverpool', 'لیورپول', 'discs/v12/club4', 7, 7),
  BmTeamDef('club_malavan', 'clubs', 'Malavan', 'ملوان', 'discs/v12/club_malavan', 7, 7),
  BmTeamDef('club2', 'clubs', 'Manchester City', 'منچستر سیتی', 'discs/v12/club2', 10, 9),
  BmTeamDef('club3', 'clubs', 'Manchester United', 'منچستر یونایتد', 'discs/v12/club3', 10, 7),
  BmTeamDef('club_meskerman', 'clubs', 'Mes Kerman', 'مس کرمان', 'discs/v12/club_meskerman', 10, 8),
  BmTeamDef('club_mesrafsanjan', 'clubs', 'Mes Rafsanjan', 'مس رفسنجان', 'discs/v12/club_mesrafsanjan', 8, 8),
  BmTeamDef('club26', 'clubs', 'Napoli', 'ناپولی', 'discs/v12/club26', 10, 10),
  BmTeamDef('club_nassaji', 'clubs', 'Nassaji Mazandaran', 'نساجی مازندران', 'discs/v12/club_nassaji', 9, 7),
  BmTeamDef('club25', 'clubs', 'Olympique Marseille', 'مارسی', 'discs/v12/club25', 10, 9),
  BmTeamDef('club9', 'clubs', 'Paris Saint-Germain', 'پاری سن ژرمن', 'discs/v12/club9', 9, 9),
  BmTeamDef('club_paykan', 'clubs', 'Paykan', 'پیکان', 'discs/v12/club_paykan', 7, 10),
  BmTeamDef('club32', 'clubs', 'Persepolis', 'پرسپولیس', 'discs/v12/club32', 9, 8),
  BmTeamDef('club16', 'clubs', 'Porto', 'پورتو', 'discs/v12/club16', 7, 7),
  BmTeamDef('club30', 'clubs', 'PSV Eindhoven', 'پی\u200cاس\u200cوی', 'discs/v12/club30', 8, 7),
  BmTeamDef('club_leipzig', 'clubs', 'RB Leipzig', 'لایپزیگ', 'discs/v12/club_leipzig', 7, 8),
  BmTeamDef('club0', 'clubs', 'Real Madrid', 'رئال مادرید', 'discs/v12/club0', 10, 10),
  BmTeamDef('club_salzburg', 'clubs', 'Red Bull Salzburg', 'سالزبورگ', 'discs/v12/club_salzburg', 7, 9),
  BmTeamDef('club18', 'clubs', 'River Plate', 'ریور پلاته', 'discs/v12/club18', 9, 9),
  BmTeamDef('club22', 'clubs', 'Roma', 'آ.اس. رم', 'discs/v12/club22', 10, 8),
  BmTeamDef('club_sanatnaft', 'clubs', 'Sanat Naft Abadan', 'صنعت نفت آبادان', 'discs/v12/club_sanatnaft', 10, 9),
  BmTeamDef('club_sepahan', 'clubs', 'Sepahan', 'سپاهان', 'discs/v12/club_sepahan', 7, 7),
  BmTeamDef('club28', 'clubs', 'Sevilla', 'سویا', 'discs/v12/club28', 7, 9),
  BmTeamDef('club_shahin', 'clubs', 'Shahin Bushehr', 'شاهین بوشهر', 'discs/v12/club_shahin', 7, 8),
  BmTeamDef('club36', 'clubs', 'Shakhtar Donetsk', 'شاختار دونتسک', 'discs/v12/club36', 9, 9),
  BmTeamDef('club27', 'clubs', 'Sporting CP', 'اسپورتینگ', 'discs/v12/club27', 8, 10),
  BmTeamDef('club24', 'clubs', 'Tottenham Hotspur', 'تاتنهام', 'discs/v12/club24', 8, 7),
  BmTeamDef('club_tractor', 'clubs', 'Tractor', 'تراکتور', 'discs/v12/club_tractor', 10, 8),
  BmTeamDef('club29', 'clubs', 'Valencia', 'والنسیا', 'discs/v12/club29', 10, 9),
  BmTeamDef('club_westham', 'clubs', 'West Ham United', 'وستهام', 'discs/v12/club_westham', 9, 7),
  BmTeamDef('club_zenit', 'clubs', 'Zenit', 'زنیت', 'discs/v12/club_zenit', 9, 9),
  BmTeamDef('club_zobahan', 'clubs', 'Zob Ahan', 'ذوب\u200cآهن', 'discs/v12/club_zobahan', 10, 8),
  BmTeamDef('nat_algeria', 'nations', 'Algeria', 'الجزایر', 'discs/v12/nat_algeria', 8, 10),
  BmTeamDef('nat0', 'nations', 'Argentina', 'آرژانتین', 'discs/v12/nat0', 10, 10),
  BmTeamDef('nat20', 'nations', 'Australia', 'استرالیا', 'discs/v12/nat20', 9, 8),
  BmTeamDef('nat9', 'nations', 'Belgium', 'بلژیک', 'discs/v12/nat9', 8, 8),
  BmTeamDef('nat1', 'nations', 'Brazil', 'برزیل', 'discs/v12/nat1', 10, 9),
  BmTeamDef('nat_cameroon', 'nations', 'Cameroon', 'کامرون', 'discs/v12/nat_cameroon', 7, 8),
  BmTeamDef('nat_chile', 'nations', 'Chile', 'شیلی', 'discs/v12/nat_chile', 8, 8),
  BmTeamDef('nat29', 'nations', 'Colombia', 'کلمبیا', 'discs/v12/nat29', 9, 10),
  BmTeamDef('nat14', 'nations', 'Croatia', 'کرواسی', 'discs/v12/nat14', 10, 8),
  BmTeamDef('nat13', 'nations', 'Denmark', 'دانمارک', 'discs/v12/nat13', 9, 7),
  BmTeamDef('nat_ecuador', 'nations', 'Ecuador', 'اکوادور', 'discs/v12/nat_ecuador', 10, 8),
  BmTeamDef('nat24', 'nations', 'Egypt', 'مصر', 'discs/v12/nat24', 8, 9),
  BmTeamDef('nat7', 'nations', 'England', 'انگلیس', 'discs/v12/nat7', 8, 10),
  BmTeamDef('nat2', 'nations', 'France', 'فرانسه', 'discs/v12/nat2', 10, 10),
  BmTeamDef('nat3', 'nations', 'Germany', 'آلمان', 'discs/v12/nat3', 10, 9),
  BmTeamDef('nat_ghana', 'nations', 'Ghana', 'غنا', 'discs/v12/nat_ghana', 10, 7),
  BmTeamDef('nat26', 'nations', 'Iran', 'ایران', 'discs/v12/nat26', 8, 8),
  BmTeamDef('nat_iraq', 'nations', 'Iraq', 'عراق', 'discs/v12/nat_iraq', 8, 7),
  BmTeamDef('nat6', 'nations', 'Italy', 'ایتالیا', 'discs/v12/nat6', 10, 8),
  BmTeamDef('nat_ivorycoast', 'nations', 'Ivory Coast', 'ساحل عاج', 'discs/v12/nat_ivorycoast', 10, 8),
  BmTeamDef('nat18', 'nations', 'Japan', 'ژاپن', 'discs/v12/nat18', 9, 9),
  BmTeamDef('nat16', 'nations', 'Mexico', 'مکزیک', 'discs/v12/nat16', 8, 10),
  BmTeamDef('nat22', 'nations', 'Morocco', 'مراکش', 'discs/v12/nat22', 9, 10),
  BmTeamDef('nat8', 'nations', 'Netherlands', 'هلند', 'discs/v12/nat8', 7, 10),
  BmTeamDef('nat_newzealand', 'nations', 'New Zealand', 'نیوزیلند', 'discs/v12/nat_newzealand', 8, 10),
  BmTeamDef('nat_nigeria', 'nations', 'Nigeria', 'نیجریه', 'discs/v12/nat_nigeria', 10, 7),
  BmTeamDef('nat12', 'nations', 'Poland', 'لهستان', 'discs/v12/nat12', 9, 9),
  BmTeamDef('nat4', 'nations', 'Portugal', 'پرتغال', 'discs/v12/nat4', 9, 7),
  BmTeamDef('nat27', 'nations', 'Qatar', 'قطر', 'discs/v12/nat27', 8, 7),
  BmTeamDef('nat28', 'nations', 'Saudi Arabia', 'عربستان', 'discs/v12/nat28', 9, 9),
  BmTeamDef('nat21', 'nations', 'Senegal', 'سنگال', 'discs/v12/nat21', 10, 7),
  BmTeamDef('nat_serbia', 'nations', 'Serbia', 'صربستان', 'discs/v12/nat_serbia', 9, 8),
  BmTeamDef('nat19', 'nations', 'South Korea', 'کره جنوبی', 'discs/v12/nat19', 8, 10),
  BmTeamDef('nat5', 'nations', 'Spain', 'اسپانیا', 'discs/v12/nat5', 10, 9),
  BmTeamDef('nat11', 'nations', 'Sweden', 'سوئد', 'discs/v12/nat11', 9, 10),
  BmTeamDef('nat15', 'nations', 'Switzerland', 'سوئیس', 'discs/v12/nat15', 10, 10),
  BmTeamDef('nat23', 'nations', 'Tunisia', 'تونس', 'discs/v12/nat23', 8, 7),
  BmTeamDef('nat_uae', 'nations', 'UAE', 'امارات', 'discs/v12/nat_uae', 10, 10),
  BmTeamDef('nat10', 'nations', 'Uruguay', 'اروگوئه', 'discs/v12/nat10', 9, 10),
  BmTeamDef('nat17', 'nations', 'USA', 'آمریکا', 'discs/v12/nat17', 8, 8),
  BmTeamDef('car_alfaromeo', 'cars', 'Alfa Romeo', 'آلفارومئو', 'discs/v12/car_alfaromeo', 8, 10),
  BmTeamDef('car7', 'cars', 'Aston Martin', 'استون مارتین', 'discs/v12/car7', 9, 9),
  BmTeamDef('car_audi', 'cars', 'Audi', 'آئودی', 'discs/v12/car_audi', 8, 9),
  BmTeamDef('car8', 'cars', 'Bentley', 'بنتلی', 'discs/v12/car8', 8, 9),
  BmTeamDef('car4', 'cars', 'BMW', 'بی\u200cام\u200cو', 'discs/v12/car4', 10, 10),
  BmTeamDef('car9', 'cars', 'Bugatti', 'بوگاتی', 'discs/v12/car9', 8, 8),
  BmTeamDef('car11', 'cars', 'Cadillac', 'کادیلاک', 'discs/v12/car11', 9, 8),
  BmTeamDef('car1', 'cars', 'Ferrari', 'فراری', 'discs/v12/car1', 9, 8),
  BmTeamDef('car_koenigsegg', 'cars', 'Koenigsegg', 'کونیگزگ', 'discs/v12/car_koenigsegg', 9, 10),
  BmTeamDef('car0', 'cars', 'Lamborghini', 'لامبورگینی', 'discs/v12/car0', 9, 10),
  BmTeamDef('car_landrover', 'cars', 'Land Rover', 'لندرور', 'discs/v12/car_landrover', 10, 10),
  BmTeamDef('car10', 'cars', 'Lexus', 'لکسوس', 'discs/v12/car10', 9, 8),
  BmTeamDef('car6', 'cars', 'Maserati', 'مازراتی', 'discs/v12/car6', 8, 8),
  BmTeamDef('car12', 'cars', 'McLaren', 'مک\u200cلارن', 'discs/v12/car12', 10, 8),
  BmTeamDef('car3', 'cars', 'Mercedes-Benz', 'مرسدس بنز', 'discs/v12/car3', 9, 9),
  BmTeamDef('car_pagani', 'cars', 'Pagani', 'پاگانی', 'discs/v12/car_pagani', 9, 8),
  BmTeamDef('car5', 'cars', 'Porsche', 'پورشه', 'discs/v12/car5', 9, 9),
  BmTeamDef('car2', 'cars', 'Rolls-Royce', 'رولزرویس', 'discs/v12/car2', 8, 9),
  BmTeamDef('car13', 'cars', 'Tesla', 'تسلا', 'discs/v12/car13', 9, 8),
  BmTeamDef('car_volvo', 'cars', 'Volvo', 'ولوو', 'discs/v12/car_volvo', 8, 9),
  BmTeamDef('lux11', 'luxury', 'Burberry', 'بربری', 'discs/v12/lux11', 10, 8),
  BmTeamDef('lux8', 'luxury', 'Cartier', 'کارتیه', 'discs/v12/lux8', 8, 8),
  BmTeamDef('lux1', 'luxury', 'Chanel', 'شنل', 'discs/v12/lux1', 10, 10),
  BmTeamDef('lux_coach', 'luxury', 'Coach', 'کوچ', 'discs/v12/lux_coach', 9, 10),
  BmTeamDef('lux5', 'luxury', 'Dior', 'دیور', 'discs/v12/lux5', 10, 10),
  BmTeamDef('lux_esteelauder', 'luxury', 'Estée Lauder', 'استی لادر', 'discs/v12/lux_esteelauder', 10, 9),
  BmTeamDef('lux9', 'luxury', 'Fendi', 'فندی', 'discs/v12/lux9', 8, 8),
  BmTeamDef('lux2', 'luxury', 'Gucci', 'گوچی', 'discs/v12/lux2', 10, 9),
  BmTeamDef('lux_hm', 'luxury', 'H&M', 'اچ\u200cاندام', 'discs/v12/lux_hm', 9, 10),
  BmTeamDef('lux3', 'luxury', 'Hermès', 'هرمس', 'discs/v12/lux3', 10, 9),
  BmTeamDef('lux_katespade', 'luxury', 'Kate Spade', 'کیت اسپید', 'discs/v12/lux_katespade', 10, 9),
  BmTeamDef('lux_lancome', 'luxury', 'Lancôme', 'لانکوم', 'discs/v12/lux_lancome', 10, 10),
  BmTeamDef('lux0', 'luxury', 'Louis Vuitton', 'لویی ویتون', 'discs/v12/lux0', 8, 10),
  BmTeamDef('lux_mac', 'luxury', 'MAC', 'مک', 'discs/v12/lux_mac', 10, 10),
  BmTeamDef('lux_pandora', 'luxury', 'Pandora', 'پاندورا', 'discs/v12/lux_pandora', 9, 10),
  BmTeamDef('lux_pink', 'luxury', 'Pink', 'پینک', 'discs/v12/lux_pink', 8, 8),
  BmTeamDef('lux4', 'luxury', 'Prada', 'پرادا', 'discs/v12/lux4', 10, 8),
  BmTeamDef('lux7', 'luxury', 'Rolex', 'رولکس', 'discs/v12/lux7', 8, 10),
  BmTeamDef('lux_sephora', 'luxury', 'Sephora', 'سفورا', 'discs/v12/lux_sephora', 10, 9),
  BmTeamDef('lux13', 'luxury', 'Swarovski', 'سواروسکی', 'discs/v12/lux13', 8, 8),
  BmTeamDef('lux_tiffany', 'luxury', 'Tiffany & Co.', 'تیفانی', 'discs/v12/lux_tiffany', 8, 10),
  BmTeamDef('lux_uniqlo', 'luxury', 'Uniqlo', 'یونیکلو', 'discs/v12/lux_uniqlo', 10, 8),
  BmTeamDef('lux10', 'luxury', 'Valentino', 'ولنتینو', 'discs/v12/lux10', 10, 10),
  BmTeamDef('lux6', 'luxury', 'Versace', 'ورساچه', 'discs/v12/lux6', 10, 10),
  BmTeamDef('lux_victoriassecret', 'luxury', "Victoria's Secret", 'ویکتوریا سیکرت', 'discs/v12/lux_victoriassecret', 9, 10),
  BmTeamDef('lux12', 'luxury', 'Yves Saint Laurent', 'ایو سن لوران', 'discs/v12/lux12', 9, 9),
  BmTeamDef('lux_zara', 'luxury', 'Zara', 'زارا', 'discs/v12/lux_zara', 10, 10),
  BmTeamDef('spt1', 'sport', 'Adidas', 'آدیداس', 'discs/v12/spt1', 8, 10),
  BmTeamDef('spt_arena', 'sport', 'Arena', 'آرنا', 'discs/v12/spt_arena', 9, 8),
  BmTeamDef('spt7', 'sport', 'Asics', 'اسیکس', 'discs/v12/spt7', 9, 10),
  BmTeamDef('spt_columbia', 'sport', 'Columbia', 'کلمبیا', 'discs/v12/spt_columbia', 10, 10),
  BmTeamDef('spt10', 'sport', 'Converse', 'کانورس', 'discs/v12/spt10', 8, 10),
  BmTeamDef('spt_dunlop', 'sport', 'Dunlop', 'دانلوپ', 'discs/v12/spt_dunlop', 10, 10),
  BmTeamDef('spt_ea7', 'sport', 'EA7', 'ای\u200cای سون', 'discs/v12/spt_ea7', 8, 8),
  BmTeamDef('spt_head', 'sport', 'Head', 'هد', 'discs/v12/spt_head', 9, 9),
  BmTeamDef('spt6', 'sport', 'Jordan', 'جردن', 'discs/v12/spt6', 8, 10),
  BmTeamDef('spt_mizuno', 'sport', 'Mizuno', 'میزونو', 'discs/v12/spt_mizuno', 8, 9),
  BmTeamDef('spt12', 'sport', 'NBA', 'ان\u200cبی\u200cای', 'discs/v12/spt12', 10, 10),
  BmTeamDef('spt4', 'sport', 'New Balance', 'نیوبالانس', 'discs/v12/spt4', 8, 8),
  BmTeamDef('spt0', 'sport', 'Nike', 'نایکی', 'discs/v12/spt0', 9, 9),
  BmTeamDef('spt2', 'sport', 'Puma', 'پوما', 'discs/v12/spt2', 9, 8),
  BmTeamDef('spt5', 'sport', 'Reebok', 'ریباک', 'discs/v12/spt5', 8, 9),
  BmTeamDef('spt_skechers', 'sport', 'Skechers', 'اسکچرز', 'discs/v12/spt_skechers', 10, 8),
  BmTeamDef('spt9', 'sport', 'Speedo', 'اسپیدو', 'discs/v12/spt9', 10, 10),
  BmTeamDef('spt_northface', 'sport', 'The North Face', 'نورث فیس', 'discs/v12/spt_northface', 9, 8),
  BmTeamDef('spt13', 'sport', 'Umbro', 'آمبرو', 'discs/v12/spt13', 9, 9),
  BmTeamDef('spt3', 'sport', 'Under Armour', 'آندر آرمور', 'discs/v12/spt3', 10, 10),
  BmTeamDef('spt11', 'sport', 'Vans', 'ونس', 'discs/v12/spt11', 8, 9),
  BmTeamDef('spt8', 'sport', 'Wilson', 'ویلسون', 'discs/v12/spt8', 8, 8),
  BmTeamDef('custom_team', 'custom', 'My Custom Team', 'تیم اختصاصی من', 'discs/v12/club32', 8, 8),
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

/// v12: exactly the four balls from the owner's 2 x 2 source sheet. The source's transparent cut-outs are centred
/// independently so every colour uses the same 418 px texture/collider contract. BmBallRenderer supplies real roll.
const List<String> kBmBallN = <String>['NX Lime', 'NX Blue', 'NX Purple', 'NX Red'];
const List<String> kBmBallFa = <String>['NX لیمویی', 'NX آبی', 'NX بنفش', 'NX قرمز'];
const List<String> kBmBallSlug = <String>['nx_ball_lime', 'nx_ball_blue', 'nx_ball_purple', 'nx_ball_red'];
const int kBmDefaultBall = 0;

/// New key resets every saved index from the removed v9 catalogue.
const String kBmBallPref = 'bm.ball.v12';

/// A saved / synced ball index -> a valid one (missing or unknown = the lime default).
int bmBallIndex(int? i) => (i == null || i < 0 || i >= kBmBallN.length) ? kBmDefaultBall : i;

/// The art of ball [i] (also its picker / shop thumbnail).
String bmBallArt(int i) => 'assets/games/bermuda/balls/v12/${kBmBallSlug[bmBallIndex(i)]}.webp';
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

/// Animated sprite-sheet balls. v12 has none: the four supplied ball textures are rolled by the 3D renderer.
const Map<int, BmAnimBall> kBmAnimBalls = <int, BmAnimBall>{};

/// Art fills: disc rim radius / half sprite size, ball radius / half frame size.
/// The painter draws every sprite so the rim lands exactly on the physics radius.
const double kBmDiscArtFill = 123 / 128;
const double kBmBallArtFill = 76 / 80;

class BmFa {
  const BmFa(this.k, this.c, this.g);
  final int k;
  final List<int> c;
  final double g;
}

const Map<String, BmFa> kBmFA = <String, BmFa>{
  // Blue/red frame lights and warm grass highlights sampled from the sole v12 pitch.
  'nx_sockerbox_owner': BmFa(1, <int>[0xFF16BFFF, 0xFFFF3B24, 0xFFFFE0A0], 0),
  // fallback used by the engine for any id without its own entry
  'stadium': BmFa(1, <int>[0xFFFFD86B, 0xFFFFFFFF, 0xFFFFE9A8], 0),
};

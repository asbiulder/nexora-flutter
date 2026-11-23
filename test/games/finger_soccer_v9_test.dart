// Finger soccer asset contract (owner request; final v12 set on 2026-11-23): the supplied Sockerbox art is the only
// pitch, the supplied lime/blue/purple/red balls are the only balls, the badge-sheet teams remain unchanged, the live
// score is shown on the art's side displays instead of a HUD, the top
// bar holds only the clock, the menu and the formation button, and the match scene runs on Flame.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/economy/gem_shop.dart';
import 'package:nexora/core/storage/local_store.dart';
import 'package:nexora/games/core/game_contract.dart';
import 'package:nexora/games/finger_soccer/core/bm_data.dart';
import 'package:nexora/games/finger_soccer/core/bm_engine.dart';
import 'package:nexora/games/finger_soccer/intro/fs_intro_data.dart';
import 'package:nexora/games/finger_soccer/intro/fs_intro_ui.dart';
import 'package:nexora/games/finger_soccer/ui/bm_painter.dart';
import 'package:nexora/games/finger_soccer/ui/bm_view.dart';
import 'package:nexora/games/finger_soccer/ui/fs_flame.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _H implements BmHooks {
  @override
  void sfx(String k, [double v = 1]) {}
  @override
  void tone(String k) {}
  @override
  void vib(List<int> pattern) {}
  @override
  void toast(String text, bool big) {}
  @override
  void goalFx() {}
  @override
  void emit(String e, Map<String, dynamic> d) {}
}

BmConfig _cfg({int field = 0, int ball = kBmDefaultBall}) => BmConfig(
    mode: 'local',
    teams: const <String>['club0', 'club1'],
    form: const <int>[0, 0],
    names: const <String>['A', 'B'],
    field: field,
    ball: ball,
    matchTime: 300);

/// Engine with only the ball (and optionally one disc) on the pitch, play running, no goal detection (remote).
BmEngine _lone({bool disc = false, int field = 0}) {
  final BmEngine e = BmEngine(_H(), rng: math.Random(3))..startMatch(_cfg(field: field));
  final BmBody keep = e.bodies.firstWhere((BmBody x) => x != e.ball);
  e.bodies.removeWhere((BmBody o) => o != e.ball && !(disc && o == keep));
  e.phase = 'move';
  e.remote = true;
  if (disc) {
    // park the ball in the opposite half, out of the way
    e.ball!
      ..x = e.CX
      ..y = e.CY
      ..vx = 0
      ..vy = 0;
  }
  return e;
}

BmBody _body(BmEngine e, bool disc) => disc ? e.bodies.firstWhere((BmBody x) => x != e.ball) : e.ball!;

const double _v = 1800;
const int _steps = 3;

/// Speed after / speed before for a body fired with ([vx], [vy]) from ([x], [y]) for a few fixed steps.
double _ratio(bool disc, double Function(BmEngine e, double r) x, double Function(BmEngine e, double r) y, double vx,
    double vy,
    {int field = 0}) {
  final BmEngine e = _lone(disc: disc, field: field);
  final BmBody b = _body(e, disc);
  b
    ..x = x(e, b.r)
    ..y = y(e, b.r)
    ..vx = vx
    ..vy = vy
    ..spin = 0;
  for (int i = 0; i < _steps; i++) {
    e.sim(STEP);
  }
  // the rebound reversed the travel direction
  if (vx != 0) expect(b.vx.sign, -vx.sign, reason: 'x not reversed');
  if (vy != 0) expect(b.vy.sign, -vy.sign, reason: 'y not reversed');
  return math.sqrt(b.vx * b.vx + b.vy * b.vy) / math.sqrt(vx * vx + vy * vy);
}

double _rail(bool disc, {int field = 0}) =>
    _ratio(disc, (BmEngine e, double r) => e.Fl + r + 2, (BmEngine e, double r) => e.CY, -_v, 0, field: field);

/// Into the back net of the top goal (team side 0 shoots at GOALS[?]: use whichever goal has d == -1).
double _backNet(bool disc, {int field = 0}) {
  final BmEngine probe = _lone(field: field);
  final int gi = probe.GOALS.indexWhere((BmGoal g) => g.d < 0);
  return _ratio(disc, (BmEngine e, double r) => (e.GOALS[gi].x1 + e.GOALS[gi].x2) / 2,
      (BmEngine e, double r) => e.GOALS[gi].y - (e.DEPTH - r - 2), 0, -_v,
      field: field);
}

/// Into the left side net, deep inside the top goal.
double _sideNet(bool disc, {int field = 0}) {
  final BmEngine probe = _lone(field: field);
  final int gi = probe.GOALS.indexWhere((BmGoal g) => g.d < 0);
  return _ratio(disc, (BmEngine e, double r) => e.GOALS[gi].x1 + r + 2,
      (BmEngine e, double r) => e.GOALS[gi].y - math.max(r * .9, e.DEPTH * .5), -_v, 0,
      field: field);
}

/// Head-on into the left post of the top goal, from the pitch side.
double _post(bool disc, {int field = 0}) {
  final BmEngine probe = _lone(field: field);
  final int gi = probe.GOALS.indexWhere((BmGoal g) => g.d < 0);
  return _ratio(disc, (BmEngine e, double r) => e.GOALS[gi].px1,
      (BmEngine e, double r) => e.GOALS[gi].y + r + e.GOALS[gi].pr + 2, 0, -_v,
      field: field);
}

void main() {
  group('v9 rebound parity (v7 rule on the v9 pitches): posts and goal nets bounce exactly like the rails', () {
    for (final bool disc in <bool>[false, true]) {
      final String who = disc ? 'disc' : 'ball';
      for (int field = 0; field < kBmFields.length; field++) {
        test('$who on field $field: back net, side net and post = rail', () {
          final double rail = _rail(disc, field: field);
          expect(rail, closeTo(kBmRailE, .06), reason: 'rail keeps ~kBmRailE (minus a few steps of felt friction)');
          // v11: a drawn net shallower than a disc (Silver Checker: 52 art px) cannot take a whole disc, so only the
          // ball is fired into the back net there
          final double r = disc ? PR : BR;
          if (_lone(field: field).DEPTH > r + 4) {
            expect(_backNet(disc, field: field), closeTo(rail, .005), reason: 'back net');
          }
          expect(_sideNet(disc, field: field), closeTo(rail, .005), reason: 'side net');
          expect(_post(disc, field: field), closeTo(rail, .005), reason: 'post');
        });
      }
    }

    test('post restitution no longer depends on speed (old ball post was 1.54-1.7 speed dependent)', () {
      double at(double v) {
        final BmEngine e = _lone();
        final BmGoal g = e.GOALS.firstWhere((BmGoal x) => x.d < 0);
        final BmBody b = e.ball!
          ..x = g.px1
          ..y = g.y + BR + g.pr + 2
          ..vx = 0
          ..vy = -v;
        for (int i = 0; i < _steps; i++) {
          e.sim(STEP);
        }
        return b.vy / v;
      }

      expect(at(600), closeTo(at(2600), .02));
    });
  });

  group('v12 pitch: only the supplied owner art, colliders measured on that art', () {
    // Image-pixel positions after mapping the supplied 1992 x 3155 art to the established logical collider geometry:
    // rails L / R / T / B, post-centre half width, tube radius, net depth and corner radius.
    const Map<String, List<double>> measured = <String, List<double>>{
      'nx_sockerbox_owner': <double>[188, 1804, 176, 2888, 285, 12.3, 177, 19.4],
    };

    test('catalog, ids, names and assets', () {
      expect(kBmFieldsRaw.map((BmField f) => f.id).toList(), <String>['nx_sockerbox_owner']);
      expect(kBmFields.length, 1);
      for (final BmField f in kBmFieldsRaw) {
        expect(f.builtInGoals, isTrue, reason: f.id);
        expect(f.fullArt, isTrue, reason: f.id);
        expect(f.faName, isNotEmpty, reason: f.id);
        expect(f.w0, 810, reason: f.id);
        expect(f.h0, 1283, reason: f.id); // supplied 1992 x 3155 portrait aspect
        expect(File(f.asset!).existsSync(), isTrue, reason: f.id);
        expect(File('assets/games/bermuda/thumbs/${f.id}.webp').existsSync(), isTrue, reason: f.id);
        expect(kBmFA.containsKey(f.id), isTrue, reason: f.id);
      }
      expect(bmFieldName(0, false), 'NX Sockerbox');
      expect(bmFieldName(0, true), 'زمین ساکرباکس NX');
      // nothing else is left in the asset folders
      final List<String> art = Directory('assets/games/bermuda/fields').listSync().map((FileSystemEntity x) => x.path).toList();
      expect(art.length, 1, reason: art.join(', '));
      expect(Directory('assets/games/bermuda/thumbs').listSync().length, 1);
      for (final String id in <String>['nx_neon_arena', 'nx_gold_checker', 'nx_gold_stripes']) {
        expect(kBmRemovedFieldIds, contains(id));
      }
      for (final String id in kBmRemovedFieldIds) {
        expect(kBmFieldsRaw.any((BmField f) => f.id == id), isFalse, reason: id);
        expect(File('assets/games/bermuda/fields/$id.webp').existsSync(), isFalse, reason: id);
        expect(File('assets/games/bermuda/thumbs/$id.webp').existsSync(), isFalse, reason: id);
      }
    });

    test('every removed/invalid pitch index falls back to the sole pitch; v12 preference key', () {
      expect(kBmFieldPref, 'bm.field.v12');
      for (final int i in <int>[1, 4, 5, 7, 29, 33, 99, -1]) {
        expect(bmFieldIndex(i), 0, reason: '$i');
      }
      expect(bmFieldIndex(null), 0);
      expect(bmFieldIndex(0), 0);
      final BmEngine e = BmEngine(_H(), rng: math.Random(1))..startMatch(_cfg(field: 17));
      expect(e.setFld, 0);
      expect(e.field.id, 'nx_sockerbox_owner');
    });

    test('geometry: walls on the drawn rail, posts on the drawn tubes, nets on the back bar', () {
      for (int fi = 0; fi < kBmFields.length; fi++) {
        final BmEngine e = BmEngine(_H(), rng: math.Random(1))..startMatch(_cfg(field: fi));
        final BmFieldS f = e.field;
        final List<double> m = measured[f.id]!;
        // art px -> world
        final double k = f.W / 1992;
        expect(f.H / 3155, closeTo(k, .002), reason: f.id);
        // the playing width keeps the established finger-soccer proportions.
        expect(e.Fw, inInclusiveRange(820, 850), reason: f.id);
        expect(2 * PR / e.Fw, closeTo(.12, .01), reason: f.id);
        // the engine's walls are exactly on the drawn rail (within the raw-unit rounding: < 1.5 art px)
        expect(e.Fl / k, closeTo(m[0], 1.5), reason: f.id);
        expect(e.Fr / k, closeTo(m[1], 1.5), reason: f.id);
        expect(e.Ft / k, closeTo(m[2], 1.5), reason: f.id);
        expect(e.Fb / k, closeTo(m[3], 1.5), reason: f.id);
        expect(e.RC / k, closeTo(m[7], 1), reason: f.id);
        // posts: centred on the centre line on the drawn tubes
        final BmGoal top = e.GOALS.firstWhere((BmGoal g) => g.d < 0);
        final BmGoal bot = e.GOALS.firstWhere((BmGoal g) => g.d > 0);
        expect((top.px1 + top.px2) / 2, closeTo(e.CX, .01));
        expect((top.px2 - top.px1) / 2 / k, closeTo(m[4], .5), reason: f.id);
        expect(top.pr / k, closeTo(m[5], .25), reason: f.id);
        expect(bot.px1, top.px1);
        expect(bot.px2, top.px2);
        // the goal lines are the rails; both goals the same depth, mirrored about the halfway line (online phones)
        expect(top.y, e.Ft);
        expect(bot.y, e.Fb);
        expect(top.y + bot.y, closeTo(2 * e.CY, .01));
        expect(e.DEPTH / k, closeTo(m[6], .5), reason: f.id);
        expect(e.DEPTH, greaterThan(2 * BR), reason: f.id);
        // mouth ~0.3 of the playing width like the reference (0.29 .. 0.34 on the five arts)
        expect((top.x2 - top.x1) / e.Fw, inInclusiveRange(.26, .36), reason: f.id);
        // the kickoff spot is the centre spot (the builder moved the drawn halfway line there)
        expect(e.KY, closeTo(e.CY, 2), reason: f.id);
      }
    });

    test('score displays: per art, left shows the bottom side, right the top side, two digits each', () {
      for (final BmFieldS f in kBmFields) {
        final BmScoreDisplay d = f.score!;
        expect(d.artW, 1992);
        final List<double> m = measured[f.id]!;
        expect(d.leftCx + d.digitW / 2, lessThan(m[0]), reason: f.id); // on the left frame, outside the rails
        expect(d.rightCx - d.digitW / 2, greaterThan(m[1]), reason: f.id); // on the right frame
        expect(d.leftCx + d.rightCx, closeTo(1992, 3), reason: f.id); // the two displays mirror each other
        expect(d.tensCy, lessThan(d.onesCy));
        expect(d.onesCy - d.tensCy, greaterThan(d.digitH), reason: f.id); // the two cells do not overlap
        expect(f.scoreLeft.toARGB32() >> 24, 0xFF, reason: f.id);
        expect(f.scoreRight.toARGB32() >> 24, 0xFF, reason: f.id);
      }
      expect(kBmFields.map((BmFieldS f) => f.score!.tensCy).toSet().length, 1);
      expect(kBmSegMasks.length, 10);
      expect(kBmSegMasks[8], 0x7F);
      expect(kBmSegMasks[1], 0x06);
    });
  });

  group('v12 balls: only the four supplied owner balls', () {
    test('catalog, default and assets', () {
      expect(kBmBallN, <String>['NX Lime', 'NX Blue', 'NX Purple', 'NX Red']);
      expect(kBmBallFa.length, 4);
      expect(kBmBallSlug.length, 4);
      expect(NB, 4);
      expect(kBmDefaultBall, 0);
      expect(kBmAnimBalls, isEmpty);
      for (int i = 0; i < NB; i++) {
        expect(File(bmBallArt(i)).existsSync(), isTrue, reason: bmBallArt(i));
        expect(bmBallThumb(i), bmBallArt(i));
      }
      expect(Directory('assets/games/bermuda/balls/v12').listSync().length, 4);
      expect(Directory('assets/games/bermuda/balls').listSync().whereType<File>(), isEmpty);
    });

    test('saved / synced ball index: missing or unknown = ball 0; v12 preference key', () {
      expect(kBmBallPref, 'bm.ball.v12');
      expect(bmBallIndex(null), 0);
      expect(bmBallIndex(4), 0);
      expect(bmBallIndex(-1), 0);
      expect(bmBallIndex(3), 3);
      final BmEngine e = BmEngine(_H(), rng: math.Random(1))..startMatch(_cfg(ball: 42));
      expect(e.setBall, 0);
    });
  });

  group('v12 teams: deduplicated owner sheets with correct categories', () {
    test('catalog, categories, complete crops and starter teams', () {
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'clubs').length, 65);
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'nations').length, 40);
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'cars').length, 20);
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'luxury').length, 27);
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'sport').length, 22);
      expect(kBmTeamDefs.where((BmTeamDef t) => t.cat == 'custom').length, 1);
      expect(kBmTeams.map((BmTeam t) => t.id).toSet().length, kBmTeamDefs.length);
      for (final BmTeam t in kBmTeams.where((BmTeam t) => t.cat != 'custom')) {
        expect(File(t.asset).existsSync(), isTrue, reason: t.asset);
        expect(t.asset.startsWith('assets/games/bermuda/discs/v12/'), isTrue, reason: t.asset);
        expect(t.faName.isNotEmpty, isTrue, reason: t.id);
        expect(t.power, inInclusiveRange(1, 10));
        expect(t.accuracy, inInclusiveRange(1, 10));
      }
      expect(Directory('assets/games/bermuda/discs/v12').listSync().length, 174);
      expect(Directory('assets/games/bermuda/discs').listSync().whereType<File>(), isEmpty);
      expect(bmTeam('club32').name, 'Persepolis');
      expect(bmTeam('club33').name, 'Esteghlal');
      expect(bmTeam('nat26').name, 'Iran');
      for (final String id in kFreeTeams) {
        expect(bmTeam(id).id, id);
      }
      expect(bmTeam(kDefaultTeam).name, 'Persepolis');
      expect(bmTeam('removed_team').id, kDefaultTeam);
    });
  });

  group('v9 match screen', () {
    void phone(WidgetTester tester) {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> pumpFor(WidgetTester tester, num seconds) async {
      for (int i = 0; i < (seconds * 4).round(); i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
    }

    GameLaunch launch() => GameLaunch(
          gameId: 'finger_soccer',
          mode: GameMode.vsBot,
          difficulty: BotDifficulty.normal,
          playerName: 'Ali',
          isFa: true,
          fancyEffects: false,
          reducedMotion: true,
          soundOn: false,
          seed: 7,
          onFinish: (_) {},
        );

    Widget host() => ProviderScope(
        child: MaterialApp(
            home: Scaffold(
                backgroundColor: Colors.black,
                // the intro flow's pick: the match starts once the saved prefs are loaded (as in the app)
                body: BermudaView(
                    launch: launch(),
                    autoStart: true,
                    pick: const FsMatchPick(teams: <String>['club32', 'club0'], forms: <int>[0, 0])))));

    Future<BmEngine> start(WidgetTester tester, Map<String, Object> prefs) async {
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(<String, Object>{'settings.lang': 'fa', 'settings.sound': false, ...prefs});
      await LocalStore.init();
      phone(tester);
      await tester.pumpWidget(host());
      await pumpFor(tester, 1);
      return (tester.state(find.byType(BermudaView)) as dynamic).matchEngine as BmEngine;
    }

    Future<void> close(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('the match runs on Flame: playfield scene, top bar (clock, menu, formation) and no HUD score',
        (WidgetTester tester) async {
      final BmEngine e = await start(tester, const <String, Object>{});
      expect(find.byType(FsMatchTopBar), findsOneWidget);
      expect(find.byType(BmChangeFormButton), findsOneWidget);
      expect(find.byType(FsClockPill), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byType(FsBarHandle), findsNothing);
      final FsFlameGame? g = (tester.state(find.byType(BermudaView)) as dynamic).flameGame as FsFlameGame?;
      expect(g, isNotNull);
      final double t0 = e.mleft;
      await pumpFor(tester, 2);
      expect(g!.frames, greaterThan(0), reason: 'the Flame loop drives the match');
      expect(e.mleft, lessThan(t0), reason: 'the match clock runs');
      // nothing covers the pitch: the top bar ends above the art and the art ends above the bottom strip
      final Rect bar = tester.getRect(find.byType(FsMatchTopBar));
      final Rect art = g.view.artRect(e);
      expect(bar.bottom, lessThanOrEqualTo(art.top + .5));
      expect(art.bottom, lessThanOrEqualTo(800 - kFsBottomStripHeight + .5));
      expect(art.left, greaterThanOrEqualTo(-7));
      expect(art.right, lessThanOrEqualTo(367));
      expect(art.width, greaterThan(360));
      // formation button still opens the picker
      await tester.tap(find.byType(BmChangeFormButton));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BmFormationCard), findsNWidgets(kBmForms.length));
      expect(tester.takeException(), isNull);
      await close(tester);
    });

    testWidgets('old saved pitch / ball picks start on pitch 0 and ball 0', (WidgetTester tester) async {
      final BmEngine e = await start(tester, <String, Object>{'bm.field': 2, 'bm.ball.v7': 5});
      expect(e.setFld, 0);
      expect(e.setBall, 0);
      expect(tester.takeException(), isNull);
      await close(tester);
    });

    testWidgets('the sole v12 pitch and a valid v12 ball preference are kept', (WidgetTester tester) async {
      final BmEngine e = await start(tester, <String, Object>{kBmFieldPref: 0, kBmBallPref: 3});
      expect(e.setFld, 0);
      expect(e.setBall, 3);
      await close(tester);
    });
  });
}

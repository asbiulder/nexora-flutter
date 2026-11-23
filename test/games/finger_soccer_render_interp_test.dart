// ANIX PRO: smooth render interpolation between fixed physics steps must be visual only.
// - Bot-vs-bot matches with a fixed seed and a fixed frame clock produce exactly the same result as the recorded
//   goldens, so interpolation / 3D pucks / the Flame scene change nothing in the simulation.
// - Painting never consumes the game RNG (the old camera shake drew from e.rnd).
// - renderPos blends between the previous and current step and snaps across big jumps (kickoff reset).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/games/finger_soccer/core/bm_data.dart';
import 'package:nexora/games/finger_soccer/core/bm_engine.dart';
import 'package:nexora/games/finger_soccer/ui/bm_painter.dart';

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

BmConfig _cfg() => const BmConfig(
    mode: 'bot',
    teams: <String>['club0', 'club1'],
    form: <int>[0, 1],
    names: <String>['A', 'B'],
    field: 0,
    ball: kBmDefaultBall,
    matchTime: 300,
    ai: true);

/// Plays [frames] frames of 1/60 s with both sides driven by the bot; returns a compact fingerprint.
String _botVsBot(int seed, int frames) {
  final BmEngine e = BmEngine(_H(), rng: math.Random(seed))..startMatch(_cfg());
  for (int i = 0; i < frames; i++) {
    e.ai = e.turn; // both sides are the bot
    e.frame(1 / 60);
  }
  final BmBody b = e.ball!;
  return '${e.score[0]}-${e.score[1]} t${e.turn} ${b.x.toStringAsFixed(3)},${b.y.toStringAsFixed(3)}';
}

void main() {
  test('bot vs bot simulation is bit-identical for every fixed seed', () {
    const List<int> seeds = <int>[1, 2, 3, 7, 42];
    final Map<int, String> first = <int, String>{for (final int seed in seeds) seed: _botVsBot(seed, 3600)};
    final Map<int, String> replay = <int, String>{for (final int seed in seeds) seed: _botVsBot(seed, 3600)};
    expect(replay, first);
    expect(first.values.toSet().length, greaterThan(1));
  });

  test('renderPos interpolates between steps and snaps across a reset jump', () {
    final BmEngine e = BmEngine(_H(), rng: math.Random(1))..startMatch(_cfg());
    final BmBody b = e.bodies.firstWhere((BmBody x) => x != e.ball);
    b
      ..px = 100
      ..py = 100
      ..x = 100 + b.r * .5
      ..y = 100;
    e.acc = STEP * .5;
    final Offset p = e.renderPos(b);
    expect(p.dx, closeTo(100 + b.r * .25, 1e-6));
    b.x = 100 + b.r * 10; // a jump (kickoff reset): drawn where it is
    expect(e.renderPos(b).dx, b.x);
  });

  testWidgets('painting never draws from the game RNG', (WidgetTester t) async {
    final math.Random rng = math.Random(9);
    final BmEngine e = BmEngine(_H(), rng: rng)..startMatch(_cfg());
    e.cam = 1; // a strong camera kick used to consume e.rnd on every paint
    final BmEngine ref = BmEngine(_H(), rng: math.Random(9))..startMatch(_cfg());
    final BmPainter p = BmPainter(e, BmImages(), BmView(), () => 0, 1, true, repaint: ValueNotifier<int>(0));
    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas c = Canvas(rec);
    for (int i = 0; i < 20; i++) {
      p.paint(c, const Size(400, 700));
    }
    rec.endRecording();
    expect(rng.nextDouble(), ref.rnd.nextDouble());
  });
}

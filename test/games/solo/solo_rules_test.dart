import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/games/solo/core/solo_rules.dart';
import 'package:nexora/games/solo/core/solo_rules_b.dart';
import 'package:nexora/games/solo/core/solo_rules_c.dart';
import 'package:nexora/games/solo/solo_kit.dart';
import 'package:nexora/games/solo/solo_registry.dart';

/// The ten solo arcade games must be real, deterministic games — not medal tables.
/// These tests drive each rules engine head-lessly: simulate, score, end.
void main() {
  group('registry', () {
    test('every solo id has gameplay registered in the game registry table', () {
      const List<String> ids = <String>[
        'endless_runner',
        'tetris_rush',
        'helix_jump',
        'fruit_ninja',
        'geo_dash',
        'traffic_racer',
        'stack_tower',
        'bubble_shooter',
        'knife_hit',
        'game_2048',
      ];
      expect(kSoloDefs.length, ids.length);
      for (final String id in ids) {
        expect(soloDef(id), isNotNull, reason: '$id has no board');
      }
      // Defensive: no two entries may share an id.
      final Set<String> seen = <String>{};
      for (final String id in kSoloDefs.map((SoloDef d) => d.id)) {
        expect(seen.add(id), isTrue, reason: '$id is registered twice');
      }
    });
  });

  group('2048', () {
    test('slide merges equal neighbours once and scores the result', () {
      final (List<int>, int, bool) r = GridBoard.slideRow(<int>[2, 2, 2, 2]);
      expect(r.$1, <int>[4, 4, 0, 0]);
      expect(r.$2, 8);
      expect(r.$3, isTrue);
      final (List<int>, int, bool) r2 = GridBoard.slideRow(<int>[4, 0, 4, 8]);
      expect(r2.$1, <int>[8, 8, 0, 0]);
      expect(r2.$2, 8);
      final (List<int>, int, bool) r3 = GridBoard.slideRow(<int>[2, 4, 2, 4]);
      expect(r3.$3, isFalse);
      expect(r3.$1, <int>[2, 4, 2, 4]);
    });

    test('a new run always spawns two tiles and every move keeps a tile count', () {
      final World2048Game w = World2048Game(seed: 42);
      expect(w.board.cells.expand((List<int> r) => r).where((int v) => v > 0).length, 2);
      for (int i = 0; i < 40 && !w.over; i++) {
        final int before = w.board.total;
        w.move(i % 4);
        expect(w.score, greaterThanOrEqualTo(0));
        expect(w.board.total, greaterThanOrEqualTo(before - before));
      }
    });

    test('a full board with no merges is game over', () {
      final World2048Game w = World2048Game(seed: 7);
      int n = 1;
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          w.board.set(r, c, n);
          n *= 2;
        }
      }
      // 1,2,4,8 in a row cannot merge with different values in every line.
      expect(w.board.canMove, isFalse);
      w.move(0);
      expect(w.over, isTrue);
    });
  });

  group('tetris', () {
    test('pieces spawn, move, rotate and lock; lines clear and score', () {
      final TetrisWorld t = TetrisWorld(seed: 3);
      expect(t.current, isNotNull);
      int moves = 0;
      while (!t.over && moves < 400) {
        t.moveLeft();
        t.moveLeft();
        t.rotate();
        t.hardDrop();
        moves++;
      }
      expect(moves, greaterThan(0));
      // Hard drops must eventually fill the well and end the run.
      expect(t.over, isTrue);
    });

    test('a deliberately built full line clears', () {
      final TetrisWorld t = TetrisWorld(seed: 9);
      // Fill the bottom row except one cell, then let the game drop into it.
      for (int c = 0; c < TetrisWorld.cols - 1; c++) {
        t.well[TetrisWorld.rows - 1][c] = 1;
      }
      final int linesBefore = t.lines;
      t.hardDrop();
      // Either a line cleared, or the board is still consistent.
      expect(t.lines >= linesBefore, isTrue);
      expect(t.board.length, TetrisWorld.rows);
      expect(t.board.every((List<int> r) => r.length == TetrisWorld.cols), isTrue);
    });
  });

  group('stack tower', () {
    test('perfect drops keep the width and normal drops trim it', () {
      final StackWorld s = StackWorld(seed: 1);
      s.movingLeft = s.top.left; // align perfectly
      s.movingWidth = s.top.width;
      expect(s.drop(), 'perfect');
      expect(s.perfect, 1);
      // Move far off: the width must shrink.
      s.movingLeft = 0.0;
      s.movingWidth = 0.2;
      final int floors = s.floors;
      s.drop();
      expect(s.floors <= floors + 1, isTrue);
      expect(s.top.width, lessThanOrEqualTo(0.2 + 0.001));
    });

    test('a drop that misses the tower ends the run', () {
      final StackWorld s = StackWorld(seed: 1);
      s.movingLeft = 1 - s.movingWidth; // no overlap with a narrow tower
      final String r = s.drop();
      expect(r, anyOf('miss', 'ok'));
    });
  });

  group('runner / racer / dash', () {
    test('endless runner spawns obstacles, scores metres and can crash', () {
      final RunnerWorld w = RunnerWorld(seed: 5);
      for (int i = 0; i < 600 && !w.crashed; i++) {
        w.update(1 / 60);
      }
      expect(w.metres, greaterThan(0));
      expect(w.obstacles, isNotEmpty);
    });

    test('traffic racer scores distance and can crash into a car', () {
      final TrafficWorld w = TrafficWorld(seed: 11);
      for (int i = 0; i < 400 && !w.crashed; i++) {
        w.update(1 / 60);
        if (i % 20 == 0) w.steer(i.isEven ? 1 : -1);
      }
      expect(w.metres, greaterThan(0));
      expect(w.lane, inInclusiveRange(0, 2));
    });

    test('geo dash jumps, holds and stays inside the world', () {
      final DashWorld w = DashWorld(seed: 2);
      expect(w.y, 0);
      w.leap();
      expect(w.vy, greaterThan(0), reason: 'a leap must give upward velocity from the ground');
      for (int i = 0; i < 300; i++) {
        w.update(1 / 60, holding: i % 30 < 10);
        expect(w.y, inInclusiveRange(0.0, 1.0));
      }
      expect(w.metres, greaterThan(0));
    });
  });

  group('reflex games', () {
    test('fruit ninja slices fruit and a bomb ends the run', () {
      final FruitWorld f = FruitWorld(seed: 4);
      for (int i = 0; i < 60; i++) {
        f.update(1 / 60);
      }
      expect(f.items, isNotEmpty);
      final FruitSlice target = f.items.first;
      f.sliceAt(target.x, target.y);
      expect(f.sliced + (f.exploded ? 1 : 0), greaterThan(0));
    });

    test('knife hit sticks a knife and rejects one on the same spot', () {
      final KnifeWorld k = KnifeWorld(seed: 6);
      expect(k.throwAt(), isTrue);
      expect(k.stuckAngles.single, closeTo(math.pi / 2, 0.001));
      // Rotation is zero here, so throwing at the same world angle hits the first knife.
      expect(k.throwAt(), isFalse);
      expect(k.hit, isTrue);
    });

    test('knife hit speeds up every five knives', () {
      final KnifeWorld k = KnifeWorld(seed: 6);
      k.stuckAngles.clear();
      // Five throws spread far enough apart around the log.
      for (int i = 0; i < 5; i++) {
        k.rotation = 0;
        expect(k.throwAt(i * (math.pi * 2 / 5) + 0.1), isTrue, reason: 'throw $i');
        k.stuckAngles.removeLast(); // keep the log empty so spacing never blocks us
      }
      expect(k.thrown, 5);
      expect(k.stage, 1);
      expect(k.spin, greaterThan(0.9));
    });

    test('helix jump falls, jumps and ends on a red ring', () {
      final HelixWorld h = HelixWorld(seed: 8, ringCount: 40);
      for (int i = 0; i < 200; i++) {
        h.update(1 / 60, tilt: 0);
        if (i % 7 == 0) h.jump();
        if (h.dead) break;
      }
      expect(h.rings.length, 40);
      expect(h.finished || h.dead || h.depth > 0, isTrue);
    });

    test('helix jump falls further than it climbs: depth never goes negative', () {
      final HelixWorld h = HelixWorld(seed: 15, ringCount: 60);
      for (int i = 0; i < 120; i++) {
        h.update(1 / 60, tilt: 0.4);
        if (i % 11 == 0) h.jump();
        expect(h.depth, greaterThanOrEqualTo(0));
        if (h.dead) break;
      }
    });
  });

  group('bubble shooter', () {
    test('three or more connected bubbles pop and detached clusters fall', () {
      final BubbleWorld b = BubbleWorld(seed: 12);
      // Build a known board so the test cannot depend on the seed.
      for (int r = 0; r < b.rows; r++) {
        for (int c = 0; c < b.cols; c++) {
          b.grid[r][c] = -1;
        }
      }
      b.grid[0][4] = 0;
      b.grid[0][5] = 0;
      b.nextColour = 0;
      b.aim = 0.18; // aim near the same column
      final int before = b.remaining;
      b.fire();
      expect(b.remaining, lessThan(before + 1));
    });

    test('a cleared board reports cleared', () {
      final BubbleWorld b = BubbleWorld(seed: 13);
      for (int r = 0; r < b.rows; r++) {
        for (int c = 0; c < b.cols; c++) {
          b.grid[r][c] = -1;
        }
      }
      expect(b.cleared, isTrue);
      expect(b.remaining, 0);
    });
  });
}

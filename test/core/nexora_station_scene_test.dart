import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/settings/app_settings.dart';
import 'package:nexora/core/ui2/nexora_station_scene.dart';

void main() {
  // The station scene is pure-Dart CustomPainter depth (no platform video/3D), so it must render
  // deterministically and respect reduced-motion without ever trapping the user.
  testWidgets('station scene renders without exceptions', (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: NexoraStationScene()),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // It paints at least one repaint boundary worth of custom paint without throwing.
    expect(find.byType(CustomPaint), findsOneWidget);
    c.dispose();
  });

  testWidgets('reduced motion produces a static scene (no continuous animation)', (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    c.read(settingsProvider).reducedMotion = true;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: NexoraStationScene()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CustomPaint), findsOneWidget);
    // The continuous spin loop is stopped under reduced motion, so repaints settle immediately.
    await expectLater(tester.pumpAndSettle(const Duration(milliseconds: 100)), completes);
    c.dispose();
  });
}

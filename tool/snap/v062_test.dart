// Dev-only v0.6.2 snapshots: Premium Ultra discs in My Teams and in the shop.
//   NX_SHOTS=/path flutter test tool/snap/v062_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nexora/core/store.dart';
import 'package:nexora/screens/shop.dart';
import 'package:nexora/screens/team.dart';
import 'package:shared_preferences/shared_preferences.dart';


final _out = Platform.environment['NX_SHOTS'] ?? '/tmp';

Future<void> _fonts() async {
  for (final (f, a) in [('Vazirmatn', 'assets/fonts/Vazirmatn-VF.ttf'), ('Orbitron', 'assets/fonts/Orbitron-VF.ttf'), ('Exo2', 'assets/fonts/Exo2-VF.ttf'), ('Oxanium', 'assets/fonts/Oxanium-VF.ttf')]) {
    final l = FontLoader(f)..addFont(rootBundle.load(a));
    await l.load();
  }
  // Material icons for the header / bar glyphs
  final mi = File('${Platform.environment['FLUTTER_ROOT'] ?? '/tmp/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (mi.existsSync()) {
    final l = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(mi.readAsBytesSync())));
    await l.load();
  }
}

final _rb = GlobalKey();

Future<void> snap(WidgetTester t, String name, Widget w, {Size phys = const Size(1080, 2340), double dpr = 2.625, Future<void> Function()? after}) async {
  t.view.physicalSize = phys;
  t.view.devicePixelRatio = dpr;
  t.view.padding = const FakeViewPadding(top: 63, bottom: 42);
  await t.pumpWidget(RepaintBoundary(key: _rb, child: MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Exo2'), home: w)));
  await t.runAsync(() async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await t.pump(const Duration(milliseconds: 50));
    }
  });
  if (after != null) await after();
  await t.pump(const Duration(milliseconds: 1200));
  await t.runAsync(() async {
    final ro = _rb.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final im = await ro.toImage(pixelRatio: dpr);
    final bd = await im.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png').writeAsBytesSync(bd!.buffer.asUint8List());
  });
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 30));
}


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.i.load();
    await _fonts();
  });
  testWidgets('team ultra', (t) async => snap(t, 'team_ultra', const TeamScreen(), phys: const Size(1080, 3200), after: () async {
        await t.tap(find.text('پریمیوم اولترا').first);
        await t.pump(const Duration(milliseconds: 600));
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 800)));
        await t.pump(const Duration(milliseconds: 600));
      }));
  testWidgets('shop ultra', (t) async => snap(t, 'shop_ultra', ShopScreen(onChest: (_) {}), phys: const Size(1080, 3600), after: () async {
        final f = find.text('Premium Ultra');
        if (f.evaluate().isNotEmpty) {
          await t.ensureVisible(f.first);
          await t.tap(f.first);
        }
        await t.pump(const Duration(milliseconds: 600));
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 800)));
        await t.pump(const Duration(milliseconds: 600));
      }));
}

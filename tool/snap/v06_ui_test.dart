// Dev-only v0.6 UI snapshots (headless, flutter_tester software renderer):
//   NX_SHOTS=/path flutter test tool/snap/v06_ui_test.dart -> main screen (each panel open) + room screen PNGs
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nexora/core/store.dart';
import 'package:nexora/online/link.dart';
import 'package:nexora/online/room_v6.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'v06_hub_cases.dart';

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

Widget roomDemo() {
  final ms = [
    const RoomMember(uid: 'h', name: 'Sara', avatar: 'club3', host: true, player: true),
    const RoomMember(uid: 'me', name: 'Pilot', avatar: 'club0', player: true, me: true),
    const RoomMember(uid: 'o', name: 'omid', avatar: 'club7', ready: true),
    const RoomMember(uid: 'g', name: 'Ghost', avatar: 'club12', online: false),
    const RoomMember(uid: 'r', name: 'REZA', avatar: 'club5', talking: true),
  ];
  final now = DateTime(2026, 11, 14, 22).millisecondsSinceEpoch;
  final chat = [
    ChatMsg('1', 'h', 'Sara', 'اوکی', now),
    ChatMsg('2', 'o', 'omid', 'تشکر سارا خانم', now + 1),
    ChatMsg('3', 'g', 'Ghost', 'کی افتاد', now + 2),
    ChatMsg('4', 'r', 'REZA', 'هیچ کس', now + 3),
    ChatMsg('5', 'me', 'Pilot', 'بزن بریم!', now + 4),
  ];
  return RoomBody(
    name: 'NEXORA-123',
    code: 'AB12CD',
    members: ms,
    chat: chat,
    me: 'me',
    picks: const ['me', 'o'],
    isHost: false,
    playing: false,
    spectators: 3,
    readyCount: 2,
    heroLabel: 'من آماده‌ام!',
    actionLabel: 'تیم و ترکیب',
    heroEnabled: true,
    tags: const ['تا ۳ گل', 'زمین کلاسیک', 'دوستانه'],
    onHero: () {},
    onAction: () {},
    onShare: () {},
    onMenu: () {},
    onAvatar: (_) {},
    onSend: (_) {},
    onReact: (_) {},
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.i.load();
    await _fonts();
  });
  testWidgets('room', (t) async => snap(t, 'room_screen', roomDemo()));
  hubCases(snap);
}

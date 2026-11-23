import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/games/arcade_kit/arcade_net.dart';
import 'package:nexora/games/core/net_link.dart';

class _Net implements NetLink {
  final StreamController<NetLiveMessage> controller = StreamController<NetLiveMessage>.broadcast();
  final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  int authority = 0;

  void liveFrom(int seat, int seq, String value) =>
      controller.add(NetLiveMessage(seat, 'snap', <String, dynamic>{'q': seq, 'v': value}));

  @override
  int get authoritySeat => authority;
  @override
  bool get isAuthority => mySeat == authority;
  @override
  String get matchId => 'm';
  @override
  int get mySeat => 2;
  @override
  int get seatCount => 3;
  @override
  int get seed => 1;
  @override
  Map<String, dynamic> get settings => const <String, dynamic>{};
  @override
  List<String> get names => const <String>['A', 'B', 'C'];
  @override
  Set<int> get connectedSeats => const <int>{0, 1, 2};
  @override
  Set<int> get forfeitedSeats => const <int>{};
  @override
  Listenable get changes => notifier;
  @override
  bool get replaying => false;
  @override
  int get desyncs => 0;
  @override
  Stream<NetLiveMessage> get live => controller.stream;
  @override
  set turnSeat(int? value) {}
  @override
  void listen(void Function(NetMove move) onMove, {VoidCallback? onReplayDone}) => onReplayDone?.call();
  @override
  Future<bool> send(Map<String, dynamic> data, {String kind = 'move', String? hash, int? asSeat}) async => true;
  @override
  void sendLive(String event, Map<String, dynamic> data) {}
  @override
  Future<void> putSecret(int seat, String slot, Map<String, dynamic> data) async {}
  @override
  Future<Map<String, dynamic>?> readSecret(String slot) async => null;
  @override
  void verify(int seq, String? expected, String actual) {}

  Future<void> close() async {
    await controller.close();
    notifier.dispose();
  }
}

void main() {
  test('host snapshots switch sequence epoch immediately after authority failover', () async {
    final _Net net = _Net();
    final ArcadeRt rt = ArcadeRt(net)..start();

    net.liveFrom(0, 900, 'old-host');
    await Future<void>.delayed(Duration.zero);
    expect(rt.snapshot?['v'], 'old-host');
    expect(rt.snapshotSeq, 900);

    // A non-authority cannot overwrite the world.
    net.liveFrom(1, 1, 'spoof');
    await Future<void>.delayed(Duration.zero);
    expect(rt.snapshot?['v'], 'old-host');

    // Once seat 1 is elected, q=1 is a new epoch and must not wait to catch q=900.
    net.authority = 1;
    net.liveFrom(1, 1, 'new-host');
    await Future<void>.delayed(Duration.zero);
    expect(rt.snapshot?['v'], 'new-host');
    expect(rt.snapshotAuthority, 1);
    expect(rt.snapshotSeq, 1);

    // A late packet from the disconnected authority is ignored.
    net.liveFrom(0, 901, 'late-old-host');
    await Future<void>.delayed(Duration.zero);
    expect(rt.snapshot?['v'], 'new-host');

    rt.dispose();
    await net.close();
  });
}

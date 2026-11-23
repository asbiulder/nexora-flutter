import 'dart:async';

import '../core/net_link.dart';

/// Real-time multiplayer on top of the existing Supabase match link (no extra game server).
///
/// Two patterns, both carried by Realtime broadcast ([NetLink.sendLive]) with the ordered move log for results:
///  * **Peer** (races, shooting duels): every phone simulates its own player and broadcasts its state ~10×/s;
///    other players are drawn from the latest state (smoothed). Finishes/eliminations are sent as logged moves so
///    every phone computes the same ranking.
///  * **Host** (arenas): the authority phone ([NetLink.isAuthority]) simulates the whole world from everyone's
///    inputs and broadcasts snapshots; the others send inputs and render snapshots. The authority posts the result
///    as a logged move ('end') which every phone applies.
class ArcadeRt {
  ArcadeRt(this.net, {this.hz = 10});
  final NetLink net;
  final double hz;

  /// Latest broadcast state per seat (peer pattern) or latest input per seat (host pattern).
  final Map<int, Map<String, dynamic>> states = <int, Map<String, dynamic>>{};
  final Map<int, DateTime> seen = <int, DateTime>{};

  /// Latest snapshot from the authority (host pattern). Sequence numbers are scoped to an authority seat: after host
  /// failover the new authority starts at 1 and must be accepted immediately instead of waiting to catch the old
  /// host's potentially huge sequence number.
  Map<String, dynamic>? snapshot;
  int snapshotSeq = 0;
  int snapshotAuthority = -1;

  /// Custom live events (emotes, hits, item throws …).
  void Function(int seat, String event, Map<String, dynamic> data)? onEvent;

  /// Logged moves (finish / eliminate / end …), in order on every phone, replayed after reconnect.
  void Function(NetMove move)? onMove;

  StreamSubscription<NetLiveMessage>? _sub;
  double _acc = 0;
  bool _started = false;

  int get mySeat => net.mySeat;
  bool get isHost => net.isAuthority;

  void start() {
    if (_started) return;
    _started = true;
    _sub = net.live.listen((NetLiveMessage m) {
      if (m.seat == net.mySeat) return;
      if (m.event == 'st' || m.event == 'in') {
        states[m.seat] = m.data;
        seen[m.seat] = DateTime.now();
      } else if (m.event == 'snap') {
        // Ignore snapshots from non-authority seats. On authority change reset the sequence epoch so q=1 from the
        // replacement host is newer than q=900 from the disconnected host.
        if (m.seat != net.authoritySeat) return;
        if (snapshotAuthority != m.seat) {
          snapshotAuthority = m.seat;
          snapshotSeq = 0;
        }
        final int q = (m.data['q'] as num?)?.toInt() ?? 0;
        if (q > snapshotSeq) {
          snapshotSeq = q;
          snapshot = m.data;
        }
      } else {
        onEvent?.call(m.seat, m.event, m.data);
      }
    });
    net.listen((NetMove mv) => onMove?.call(mv));
  }

  /// Throttled broadcast of this phone's state (peer) or input (host pattern, event 'in').
  void pump(double dt, Map<String, dynamic> Function() build, {String event = 'st'}) {
    _acc += dt;
    if (_acc < 1 / hz) return;
    _acc = 0;
    net.sendLive(event, build());
  }

  int _q = 0;

  /// Authority only: broadcast a world snapshot (throttled by the caller's [pump] cadence).
  double _accS = 0;
  void pumpSnapshot(double dt, Map<String, dynamic> Function() build) {
    _accS += dt;
    if (_accS < 1 / hz) return;
    _accS = 0;
    final Map<String, dynamic> s = build();
    s['q'] = ++_q;
    net.sendLive('snap', s);
  }

  void event(String e, Map<String, dynamic> data) => net.sendLive(e, data);

  /// Logged result message. Arcade finish/elimination rows are self-contained and may be posted by several phones
  /// on the same frame, so they use the floating queue: a lost seq is re-posted instead of rebuilding a live race.
  Future<bool> log(Map<String, dynamic> data) => net.send(<String, dynamic>{...data, kNetFloat: true});

  /// Seats still in the match (connected or not, but not forfeited).
  List<int> get activeSeats => <int>[
        for (int s = 0; s < net.seatCount; s++)
          if (!net.forfeitedSeats.contains(s)) s
      ];

  bool isStale(int seat, [Duration d = const Duration(seconds: 6)]) {
    final DateTime? t = seen[seat];
    return t == null || DateTime.now().difference(t) > d;
  }

  void dispose() {
    unawaited(_sub?.cancel());
  }
}

/// Smooths a remote value toward its latest network sample.
double rtLerp(double cur, double target, double dt, [double rate = 12]) {
  final double k = (dt * rate).clamp(0.0, 1.0);
  return cur + (target - cur) * k;
}

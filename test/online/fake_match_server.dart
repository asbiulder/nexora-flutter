// In-memory stand-in for the games project's match log (nx_matches + nx_match_moves + nx_push_move), used to run
// two (or more) real SupabaseMatchLink instances against one server in tests.
import 'dart:async';

import 'package:nexora/core/online/match_link.dart';

class FakeMatchServer {
  FakeMatchServer({required this.players, this.legacyTurnGate = false, this.seed = 4242, this.settings});

  final List<String> players;

  /// Reproduces 20261117350000_g_turn_authority (the buggy server function): every non-snap/system/forfeit move
  /// must come from turn_seat, and each one rotates turn_seat.
  final bool legacyTurnGate;
  final int seed;
  final Map<String, dynamic>? settings;
  final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
  int lastSeq = 0;
  int turnSeat = 0;
  String status = 'playing';
  int refused = 0;

  /// Extra latency before a push lands (lets two phones race for the same seq).
  Duration latency = Duration.zero;

  Map<String, dynamic> get matchRow => <String, dynamic>{
        'players': players,
        'names': <String>[for (int i = 0; i < players.length; i++) 'P$i'],
        'seed': seed,
        'game': 'finger_soccer',
        'room_id': null,
        'settings': settings ?? <String, dynamic>{},
        'status': status,
      };

  MatchBackend backendFor(String uid) => _Backend(this, uid);

  Map<String, dynamic> push(String uid, int seq, String kind, Map<String, dynamic> move, String? hash, int seat) {
    final int caller = players.indexOf(uid);
    if (caller < 0) throw StateError('not a player');
    if (status != 'playing') return <String, dynamic>{'ok': false, 'reason': 'over'};
    if (seq != lastSeq + 1) return <String, dynamic>{'ok': false, 'reason': 'seq', 'last_seq': lastSeq};
    if (seat != caller && !<String>{'snap', 'timeout', 'forfeit', 'system'}.contains(kind)) {
      throw StateError('seat mismatch');
    }
    if (legacyTurnGate && !<String>{'snap', 'system', 'forfeit'}.contains(kind)) {
      if (seat != turnSeat) {
        refused++;
        return <String, dynamic>{'ok': false, 'reason': 'turn', 'turn_seat': turnSeat};
      }
      turnSeat = (turnSeat + 1) % players.length;
    }
    rows.add(<String, dynamic>{
      'seq': seq,
      'seat': seat,
      'kind': kind,
      'move': Map<String, dynamic>.from(move),
      'hash': hash,
      'by_user': uid,
    });
    lastSeq = seq;
    return <String, dynamic>{'ok': true, 'seq': seq};
  }
}

class _Backend implements MatchBackend {
  _Backend(this.s, this.uid);
  final FakeMatchServer s;
  final String uid;

  @override
  Future<dynamic> pushMove(int seq, String kind, Map<String, dynamic> move, String? hash, int seat) async {
    if (s.latency > Duration.zero) await Future<void>.delayed(s.latency);
    return s.push(uid, seq, kind, move, hash, seat);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMoves(int after) async =>
      <Map<String, dynamic>>[for (final Map<String, dynamic> r in s.rows) if ((r['seq'] as int) > after) r];

  @override
  Future<Map<String, dynamic>?> fetchStatus() async => <String, dynamic>{'status': s.status};
}

SupabaseMatchLink fakeLink(FakeMatchServer s, int seat, {Duration poll = const Duration(milliseconds: 50)}) =>
    SupabaseMatchLink.test(s.backendFor(s.players[seat]), 'm1', s.players[seat], s.matchRow, poll: poll);

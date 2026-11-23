# Multiplayer v8 — full-stack recovery pass

Date: 2026-11-23  
Games project: `eyzafhrefnqlwcjpcdyg`  
Migration: `supabase/games/migrations/20261123300000_g_multiplayer_v8.sql`

## Scope

All 16 online games use the same authenticated match log and presence layer:

- Finger Soccer, Carrom, Billiards, Backgammon, Ludo, Snakes & Ladders, NX Cards, Quiz, Mafia
- Kart Racing, Obstacle Race, Bomb Arena, 8 Ball Pool, Mini Golf, Basketball Battle, Spy & Mafia

## Fixed

- **Connected idle deadlocks:** deterministic games publish a server-checked turn lease. The elected authority can
  forfeit the current seat only after the durable deadline. This complements (not replaces) v7's disconnected-seat
  heartbeat rule. The default fallback is 90 seconds; room/tournament `turn_sec` can choose 30–300 seconds.
- **Authority failover in host-simulated games:** snapshot sequence numbers are scoped to the authority seat. A new
  Bomb Arena host starts at sequence 1 immediately; clients no longer reject its snapshots until it catches the old
  host's sequence.
- **Simultaneous result races:** arcade finish/elimination rows and simultaneous Mafia/Spy votes use the floating
  append queue. Losing a sequence race re-posts the action instead of rebuilding a live match.
- **Obstacle Race hangs:** DNF/elimination is now a durable `out` row. The authority writes one final ranking row;
  every phone reports the same order.
- **Kart Racing disagreement:** the authority persists the complete final order, including DNF progress and forfeits.
- **Basketball disagreement:** phones no longer decide from a stale score broadcast after five seconds. The authority
  freezes every score in one durable end row before result reporting.
- **Mafia ready/idle hang:** intro timeouts now produce `ready` (the old `final` action was ignored). A one-second
  watchdog automatically files neutral actions after 90 seconds, including when the authority itself is idle.
- **Quiz/Mafia result blocker:** the live trigger claimed Mafia was server-authoritative although no Mafia server
  state/action RPC exists, blocking normal completion. Mafia now uses the existing multi-phone consensus result path;
  Quiz is strictly guarded only when `nx_quiz_start` actually activated its server engine.
- **Tournament launch metadata:** `tournamentMatchId` is passed into every online game launch.

## Safety properties

- Turn publication and idle forfeits are `SECURITY DEFINER` RPCs with explicit authenticated grants.
- The server independently elects the lowest recently active, non-forfeited seat; a client cannot declare itself
  authority.
- Turn state is private (RLS enabled, no `anon`/`authenticated` table grants).
- Turn epochs make heartbeat re-publication idempotent while allowing a same-seat extra turn to get a new deadline.
- Result end rows carry enough state/order for replay after reconnect.

## Regression coverage

- Authority election and bounded turn fallback.
- Snapshot epoch reset on host failover and rejection of non-authority/late-old-host snapshots.
- DNF → durable out conversion and idempotent replay.
- Registry assertion that exactly all 16 multiplayer engines are wired online.

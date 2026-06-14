import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/knowledge_provider.dart';

/// Full Gamification Stats Section — Phase 7B updated:
/// Level title/emoji, real XP progress bar, streak, hearts
class GamificationStatsWidget extends ConsumerWidget {
  const GamificationStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamAsync = ref.watch(gamificationProvider);

    return gamAsync.when(
      loading: () => _buildSkeleton(),
      error:   (_, __) => const SizedBox.shrink(),
      data:    (stats) => _buildStats(context, stats),
    );
  }

  // ── Skeleton ────────────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
      ),
      height: 160,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
      ),
    );
  }

  // ── Live stats ──────────────────────────────────────────────────────────
  Widget _buildStats(BuildContext context, dynamic stats) {
    final int xp            = stats.xp ?? 0;
    final int hearts        = stats.hearts ?? 5;
    final int streak        = stats.currentStreak ?? 0;
    // Phase 7B: real level data from API
    final int level         = stats.level ?? 1;
    final String levelTitle = stats.levelTitle ?? 'Beginner';
    final String levelEmoji = stats.levelEmoji ?? '🌱';
    final int xpToNext      = stats.xpToNext ?? 100;
    final int levelProgPct  = stats.levelProgress ?? 0;
    final double progress   = (levelProgPct / 100.0).clamp(0.0, 1.0);
    // Phase 7C: Shield
    final bool shieldActive = stats.streakShieldActive ?? false;
    // Phase 7D: Daily goal
    final int dailyGoal     = stats.dailyGoal ?? 3;
    final int dailyDone     = stats.dailyNodesToday ?? 0;
    final double dailyPct   = dailyGoal > 0 ? (dailyDone / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final bool goalDone     = dailyDone >= dailyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.12),
            blurRadius: 20, spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Level badge + Streak + Hearts ────────────────────────
          Row(
            children: [
              // Level badge with real title (Phase 7B)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(levelEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      'Lv.$level $levelTitle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Phase 7C: Shield badge next to streak
              _StatChip(
                icon: shieldActive ? '🛡️🔥' : '🔥',
                value: '$streak',
                label: shieldActive ? 'Shield' : 'Streak',
                color: shieldActive ? Colors.tealAccent : Colors.orange,
              ),
              const SizedBox(width: 12),
              _StatChip(icon: '❤️', value: '$hearts', label: 'Hearts', color: Colors.redAccent),
            ],
          ),

          const SizedBox(height: 18),

          // ── Row 2: XP label + to-next ───────────────────────────────────
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '$xp XP',
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                xpToNext > 0 ? '$xpToNext XP to next level' : '👑 Max Level!',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── XP Progress Bar (real % from API) ───────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Phase 7D: Daily Goal Progress ─────────────────────────────
          Row(
            children: [
              Text(
                goalDone ? '🎯 Daily Goal Done!' : '🎯 Daily: $dailyDone / $dailyGoal nodes',
                style: TextStyle(
                  color: goalDone ? Colors.greenAccent : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (ctx, c) => Stack(
              children: [
                Container(
                  height: 7,
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 7,
                  width: c.maxWidth * dailyPct,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: goalDone
                          ? [Colors.greenAccent, Colors.tealAccent]
                          : [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable stat chip ───────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color, fontSize: 15, fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

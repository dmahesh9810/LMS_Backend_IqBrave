import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/knowledge_provider.dart';

/// Full Gamification Stats Section:
/// XP progress bar → Level, Streak 🔥, Hearts ❤️, Module % ring
class GamificationStatsWidget extends ConsumerWidget {
  const GamificationStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamAsync = ref.watch(gamificationProvider);

    return gamAsync.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) => _buildStats(stats),
    );
  }

  // ── Shimmer-style skeleton while loading ────────────────────────────────
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
  Widget _buildStats(dynamic stats) {
    final int xp          = stats.xp ?? 0;
    final int hearts      = stats.hearts ?? 3;
    final int streak      = stats.currentStreak ?? 0;
    final int level       = (xp / 100).floor() + 1;
    final int xpProgress  = xp % 100; // XP within current level
    final double progress = xpProgress / 100.0;

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
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Level badge + Streak + Hearts ──────────────────────
          Row(
            children: [
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Level $level',
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

              // Streak
              _StatChip(
                icon: '🔥',
                value: '$streak',
                label: 'Streak',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),

              // Hearts
              _StatChip(
                icon: '❤️',
                value: '$hearts',
                label: 'Hearts',
                color: Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Row 2: XP bar ──────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '$xp XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '$xpProgress / 100 to Level ${level + 1}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── XP Progress Bar ────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                height: 10,
                width: progress *
                    (MediaQueryData.fromView(
                              WidgetsBinding.instance.platformDispatcher.views.first,
                            ).size.width -
                            80),
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
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

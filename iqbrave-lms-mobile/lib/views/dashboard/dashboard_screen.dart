import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/knowledge_provider.dart';
import 'widgets/gamification_stats_widget.dart';
import 'widgets/module_completion_ring_widget.dart';
import 'widgets/daily_revision_card.dart';
import 'widgets/radar_chart_widget.dart';
import 'leaderboard_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user      = authState.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF161B22),
        onRefresh: () async {
          ref.invalidate(spacedRepetitionProvider);
          ref.invalidate(learningPathProvider);
          ref.invalidate(gamificationProvider);
        },
        child: CustomScrollView(
        slivers: [
          // ── Premium Dark App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D1117),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IQBrave LMS',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Hi, ${(user?.name ?? 'Student').split(' ').first} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
          ),

          // ── Body Content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Gamification Stats Card (XP + Streak + Hearts) ─────
                const GamificationStatsWidget(),
                const SizedBox(height: 16),

                // ── Daily Revision Card (Spaced Repetition) ────────────
                const DailyRevisionCard(),
                const SizedBox(height: 16),

                // ── Module Completion Donut Ring ───────────────────────
                const ModuleCompletionRingWidget(),
                const SizedBox(height: 16),

                // ── Quick Action: Go to Course ─────────────────────────
                _QuickActionCard(),
                const SizedBox(height: 24),

                // ── Knowledge Radar ────────────────────────────────────
                const _SectionTitle(title: 'Knowledge Radar', icon: Icons.radar),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Consumer(builder: (context, ref, _) {
                    final radarAsync = ref.watch(radarDataProvider);
                    return radarAsync.when(
                      data: (data) => RadarChartWidget(data: data),
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2)),
                      ),
                      error: (e, st) => Center(
                        child: Text('Chart unavailable', style: TextStyle(color: Colors.white38)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // ── Focus Areas ────────────────────────────────────────
                const _SectionTitle(title: 'Focus Areas', icon: Icons.track_changes),
                const SizedBox(height: 12),
                Consumer(builder: (context, ref, _) {
                  final weakAsync = ref.watch(weaknessesProvider);
                  return weakAsync.when(
                    data: (weaknesses) {
                      if (weaknesses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 22),
                              SizedBox(width: 12),
                              Text(
                                "Great job! No major weak areas right now.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weaknesses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = weaknesses[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.warning_amber, color: Colors.redAccent, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.topicName,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('Mastery: ${item.score.toStringAsFixed(0)}%',
                                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                    ),
                    error: (e, st) => const SizedBox.shrink(),
                  );
                }),
              ]),
            ),
          ),
        ],
        ),         // end CustomScrollView
      ),           // end RefreshIndicator
    );
  }
}

// ── Quick Action Card ────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to courses tab (index 1)
        // This works because MainWrapper controls the index
        DefaultTabController.maybeOf(context)?.animateTo(1);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Learning',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'M01 - Maintaining Files & Folders',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/course_provider.dart';
import '../../quizzes/micro_topic_quiz_screen.dart';

/// 📚 Daily Revision Card — shown on dashboard when spaced repetition topics are due.
/// Hides itself automatically when there's nothing to review.
class DailyRevisionCard extends ConsumerWidget {
  const DailyRevisionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revisionAsync = ref.watch(spacedRepetitionProvider);

    return revisionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (topics) {
        if (topics.isEmpty) return const SizedBox.shrink(); // nothing to review!

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ───────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔁', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Revision',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Spaced repetition — master your weak spots!',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Topic Cards ──────────────────────────────────────────
            ...topics.map((topic) => _RevisionTopicCard(topic: topic)),
          ],
        );
      },
    );
  }
}

class _RevisionTopicCard extends StatelessWidget {
  final dynamic topic;
  const _RevisionTopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final int topicId   = topic['micro_topic_id'] as int;
    final String title  = topic['title'] as String? ?? 'Unknown';
    final int failCount = topic['fail_count'] as int? ?? 1;
    final String ago    = topic['last_failed_at'] as String? ?? 'recently';
    final bool practical = topic['is_practical'] as bool? ?? false;

    // Color intensity based on fail count
    final Color urgencyColor = failCount >= 4
        ? Colors.redAccent
        : failCount >= 2
            ? Colors.orange
            : Colors.amber;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MicroTopicQuizScreen(
              microTopicId: topicId,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: urgencyColor.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: urgencyColor.withValues(alpha: 0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  practical ? '⚙️' : '📖',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Topic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.close_rounded, color: urgencyColor, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '$failCount failed attempt${failCount > 1 ? 's' : ''} · $ago',
                        style: TextStyle(color: urgencyColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Urgency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Review',
                style: TextStyle(
                  color: urgencyColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

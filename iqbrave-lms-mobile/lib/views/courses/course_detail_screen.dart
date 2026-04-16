import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../providers/knowledge_provider.dart';
import '../../core/theme/app_theme.dart';
import '../quizzes/micro_topic_quiz_screen.dart';
import '../main/widgets/gamification_app_bar_widget.dart';
import 'widgets/learning_path_map.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final gamificationState = ref.watch(gamificationProvider);
    final learningPathAsync = ref.watch(learningPathProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: gamificationState.when(
        data: (stats) => GamificationAppBarWidget(
          streakDays: stats.currentStreak,
          xp: stats.xp,
          hearts: stats.hearts,
        ),
        loading: () => const GamificationAppBarWidget(),
        error: (_, __) => const GamificationAppBarWidget(),
      ),
      body: learningPathAsync.when(
        data: (pathData) {
          final title = pathData['course_title'] ?? 'Gamified NVQ Course';
          final nodes = pathData['nodes'] as List<dynamic>;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              // Gamified Duolingo Winding Roadmap
              SliverFillRemaining(
                child: LearningPathMap(
                  nodes: nodes,
                  onNodeTap: (node) async {
                    // 🔒 Don't allow locked nodes
                    if (node['status'] == 'locked') return;

                    final topicId = node['id'] as int;
                    final title   = node['title'] as String? ?? 'Topic';

                    // Navigate (both types go through MicroTopicQuizScreen
                    // which auto-detects is_practical and redirects if needed)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MicroTopicQuizScreen(
                          microTopicId: topicId,
                          title: title,
                        ),
                      ),
                    );

                    // 🔄 Refresh the learning path after returning
                    // so completed nodes turn green immediately
                    ref.invalidate(learningPathProvider);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load map: $e')),
      ),
    );
  }
}

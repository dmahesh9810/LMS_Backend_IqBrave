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
    final gamificationState  = ref.watch(gamificationProvider);
    final learningPathAsync  = ref.watch(learningPathProvider);
    final nodeMasteryAsync   = ref.watch(nodeMasteryProvider);   // Phase 6

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: gamificationState.when(
        data:    (s) => GamificationAppBarWidget(streakDays: s.currentStreak, xp: s.xp, hearts: s.hearts),
        loading: ()  => const GamificationAppBarWidget(),
        error:   (_, __) => const GamificationAppBarWidget(),
      ),
      body: learningPathAsync.when(
        data: (pathData) {
          final title  = pathData['course_title'] ?? 'Gamified NVQ Course';
          final nodes  = pathData['nodes'] as List<dynamic>;

          // Phase 6: resolve mastery map (empty map if still loading)
          final masteryMap = nodeMasteryAsync.asData?.value ?? {};

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
              SliverFillRemaining(
                child: LearningPathMap(
                  nodes:      nodes,
                  masteryMap: masteryMap,
                  onNodeTap:  (node) async {
                    if (node['status'] == 'locked') return;

                    final topicId = node['id'] as int;
                    final title   = node['title'] as String? ?? 'Topic';

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MicroTopicQuizScreen(
                          microTopicId: topicId,
                          title: title,
                        ),
                      ),
                    );

                    // 🔄 Refresh path + mastery after quiz
                    ref.invalidate(learningPathProvider);
                    ref.invalidate(nodeMasteryProvider);   // Phase 6
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Failed to load map: $e')),
      ),
    );
  }
}

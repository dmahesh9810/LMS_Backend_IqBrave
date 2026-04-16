import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quiz_provider.dart';
import '../../core/theme/app_theme.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int quizId;
  final String title;

  const QuizScreen({super.key, required this.quizId, required this.title});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final Map<int, int> _selectedAnswers = {}; // questionId -> optionId
  bool _isSubmitting = false;

  void _submitQuiz(List<dynamic> questions) async {
    if (_selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final answersList = _selectedAnswers.entries.map((e) => {
      'question_id': e.key,
      'selected_option_id': e.value,
      'time_taken_seconds': 10, // hardcoded for now, standard timer tracking can be added
    }).toList();

    final score = await ref.read(quizUploaderProvider).submitQuiz(widget.quizId, answersList);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (score != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Quiz Completed! 🎉'),
            content: Text('You scored $score marks.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting quiz. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizDetailProvider(widget.quizId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: AppTheme.textPrimaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: quizAsync.when(
        data: (quiz) {
          if (quiz.questions.isEmpty) {
            return const Center(child: Text("No questions found in this quiz."));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}: ${question.questionText}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ...question.options.map((option) {
                              return RadioListTile<int>(
                                activeColor: AppTheme.primaryColor,
                                contentPadding: EdgeInsets.zero,
                                title: Text(option.optionText),
                                value: option.id,
                                groupValue: _selectedAnswers[question.id],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedAnswers[question.id] = val;
                                    });
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitQuiz(quiz.questions),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Quiz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load quiz: $e')),
      ),
    );
  }
}

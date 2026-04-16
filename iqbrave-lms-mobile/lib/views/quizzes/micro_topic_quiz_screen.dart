import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../providers/knowledge_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import 'practical_upload_screen.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/iqbot_sheet.dart';

class MicroTopicQuizScreen extends ConsumerStatefulWidget {
  final int microTopicId;
  final String title;

  const MicroTopicQuizScreen({
    super.key,
    required this.microTopicId,
    required this.title,
  });

  @override
  ConsumerState<MicroTopicQuizScreen> createState() => _MicroTopicQuizScreenState();
}

class _MicroTopicQuizScreenState extends ConsumerState<MicroTopicQuizScreen> {
  int _currentQuestionIndex = 0;
  bool _showCelebration = false;
  String? _selectedAnswer;
  bool _isChecking = false;
  bool? _isCorrect;

  List<Map<String, dynamic>> _questions = [];
  String _contentHtml = '';
  String? _videoUrl;        // ← NEW: YouTube URL from API
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopicData();
  }

  @override
  void dispose() {
    // 🔄 Refresh spaced repetition + learning path on dashboard when we leave
    ref.invalidate(spacedRepetitionProvider);
    ref.invalidate(learningPathProvider);
    super.dispose();
  }

  Future<void> _fetchTopicData() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get('/v1/micro-topics/${widget.microTopicId}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];

        // 🤖 If this is a Practical Node, redirect to PracticalUploadScreen
        final isPractical = data['is_practical'] == true;
        if (isPractical && mounted) {
          final gradingRules = data['grading_rules'];
          String instructions = 'Follow the instructions to complete this practical task, then upload your ZIP file.';
          if (gradingRules != null) {
            if (gradingRules['required_folder'] != null) {
              instructions = 'Desktop එකේ "${gradingRules['required_folder']}" කියලා Folder එකක් හදලා, '
                  '${gradingRules['required_file'] != null ? '"${gradingRules['required_file']}" නමැති Text File එකක් ඒ ඇතුළට දාලා, ' : ''}'
                  'ඒ Folder ZIP කරලා මෙතනට Upload කරන්න.';
            }
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PracticalUploadScreen(
                microTopicId: widget.microTopicId,
                title: widget.title,
                instructions: instructions,
              ),
            ),
          );
          return;
        }

        setState(() {
          _contentHtml = data['content_html'] ?? '';
          _videoUrl    = data['video_url'];   // ← Store video URL
          _questions = List<Map<String, dynamic>>.from(data['questions']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAnswer() async {
    if (_selectedAnswer == null) return;
    setState(() => _isChecking = true);

    final correct = _selectedAnswer == _questions[_currentQuestionIndex]['answer'];
    setState(() {
      _isCorrect = correct;
    });

    // Target the specific Backend gamification status endpoint
    try {
      final dio = ref.read(apiClientProvider).dio;
      // Send attempt payload (is_correct boolean flag tells engine to increase XP or drop heart)
      await dio.post('/v1/micro-topics/${widget.microTopicId}/attempt', data: {
        'is_correct': correct,
        'concept_id': 1 
      });

      // Synchronize frontend UI provider immediately
      if (correct) {
        ref.read(gamificationProvider.notifier).addXp(10);
      } else {
        ref.read(gamificationProvider.notifier).reduceHeart();
      }
    } catch (e) {
      // Ignore API errors gracefully during visual UI interactions
    }

    setState(() => _isChecking = false);
  }

  void _nextOrFinish() {
    if (_isCorrect == true && _currentQuestionIndex == _questions.length - 1) {
      // Completed last question, pop celebration animation!
      setState(() {
        _showCelebration = true;
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (_isCorrect == true) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isCorrect = null;
      });
    } else {
      // Retry same question on failure
      setState(() {
        _selectedAnswer = null;
        _isCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation for high dopamine hit!
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_U10R4k.json', 
                height: 250,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, size: 100, color: Colors.amber),
              ),
              const SizedBox(height: 24),
              const Text(
                'Lesson Complete!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text(
                '+20 XP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              )
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), elevation: 0),
        body: Center(
          child: Text('Content: $_contentHtml\n\nNo questions available for this module.', textAlign: TextAlign.center,),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final options = (question['options'] as List).cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      // ── Sticky Bottom Buttons ────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🤖 IQ-Bot button — visible only when answer is wrong
              if (_isCorrect == false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purpleAccent,
                        side: const BorderSide(color: Colors.purpleAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Text('🤖', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        'Ask IQ-Bot — Why was I wrong?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => showIQBotExplanation(
                        context, ref,
                        question:      question['question'] as String,
                        wrongAnswer:   _selectedAnswer ?? '',
                        correctAnswer: question['answer'] as String,
                        topicTitle:    widget.title,
                      ),
                    ),
                  ),
                ),
              // Check / Continue / Try Again
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect != null
                        ? (_isCorrect! ? Colors.green : Colors.red)
                        : (_selectedAnswer == null
                            ? Colors.grey.shade300
                            : Colors.blue),
                    foregroundColor: _selectedAnswer == null && _isCorrect == null
                        ? Colors.grey.shade600
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _selectedAnswer == null || _isChecking
                      ? null
                      : () {
                          if (_isCorrect == null) {
                            _checkAnswer();
                          } else {
                            _nextOrFinish();
                          }
                        },
                  child: _isChecking
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isCorrect == null
                              ? 'Check'
                              : (_isCorrect! ? 'Continue' : 'Try Again'),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                color: Colors.green,
                backgroundColor: Colors.grey.shade200,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 16),
              // 🎬 Video Player (shown only if backend provides a URL)
              if (_videoUrl != null && _videoUrl!.isNotEmpty)
                VideoPlayerWidget(
                  videoUrl: _videoUrl!,
                  title: widget.title,
                ),
              const SizedBox(height: 16),
              Text(
                question['question'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Answer Options
              ...options.map((opt) {
                final isSelected = _selectedAnswer == opt;
                Color borderColor = Colors.grey.shade300;
                Color bgColor = Colors.transparent;

                if (isSelected) {
                  borderColor = Colors.blue;
                  bgColor = Colors.blue.withValues(alpha: 0.1);
                  if (_isCorrect == true) {
                    borderColor = Colors.green;
                    bgColor = Colors.green.withValues(alpha: 0.1);
                  } else if (_isCorrect == false) {
                    borderColor = Colors.red;
                    bgColor = Colors.red.withValues(alpha: 0.1);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: InkWell(
                    onTap: _isCorrect != null
                        ? null
                        : () => setState(() => _selectedAnswer = opt),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: bgColor,
                      ),
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../providers/auth_provider.dart';

/// Shows the IQ-Bot explanation in a premium bottom sheet.
/// Called from quiz screen when student gets wrong answer.
Future<void> showIQBotExplanation(
  BuildContext context,
  WidgetRef ref, {
  required String question,
  required String wrongAnswer,
  required String correctAnswer,
  required String topicTitle,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IQBotSheet(
      ref: ref,
      question: question,
      wrongAnswer: wrongAnswer,
      correctAnswer: correctAnswer,
      topicTitle: topicTitle,
    ),
  );
}

class _IQBotSheet extends StatefulWidget {
  final WidgetRef ref;
  final String question;
  final String wrongAnswer;
  final String correctAnswer;
  final String topicTitle;

  const _IQBotSheet({
    required this.ref,
    required this.question,
    required this.wrongAnswer,
    required this.correctAnswer,
    required this.topicTitle,
  });

  @override
  State<_IQBotSheet> createState() => _IQBotSheetState();
}

class _IQBotSheetState extends State<_IQBotSheet> {
  String _explanation = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExplanation();
  }

  Future<void> _fetchExplanation() async {
    try {
      final dio = widget.ref.read(apiClientProvider).dio;
      final response = await dio.post(
        '/v1/iqbot/explain',
        data: {
          'question':       widget.question,
          'wrong_answer':   widget.wrongAnswer,
          'correct_answer': widget.correctAnswer,
          'topic_title':    widget.topicTitle,
        },
        options: Options(contentType: 'application/json'),
      );

      setState(() {
        _explanation = response.data['data']['explanation'] ?? 'No explanation available.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _explanation = 'Review your notes and try again! 💪';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withValues(alpha: 0.4),
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IQ-Bot Explains',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Powered by Google Gemini AI',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white38),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white10),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Wrong / Right chips
                  Row(
                    children: [
                      _AnswerChip(
                        label: widget.wrongAnswer,
                        isCorrect: false,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white24, size: 16),
                      const SizedBox(width: 8),
                      _AnswerChip(
                        label: widget.correctAnswer,
                        isCorrect: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Explanation body
                  if (_isLoading)
                    _buildLoadingState()
                  else
                    _buildExplanationText(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            color: Colors.purpleAccent,
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '🤖 IQ-Bot is thinking...',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildExplanationText() {
    // Parse bold **text** markers for simple formatting
    final lines = _explanation.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        final isHeader = line.startsWith('❌') ||
            line.startsWith('✅') ||
            line.startsWith('💡');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            line.replaceAll('**', ''),
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.white70,
              fontSize: isHeader ? 15 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final bool isCorrect;

  const _AnswerChip({required this.label, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.redAccent;
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
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

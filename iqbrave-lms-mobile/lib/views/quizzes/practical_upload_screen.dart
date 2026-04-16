import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import '../../providers/knowledge_provider.dart';
import '../../providers/auth_provider.dart';

enum _UploadState { idle, picking, uploading, grading, passed, failed }

class PracticalUploadScreen extends ConsumerStatefulWidget {
  final int microTopicId;
  final String title;
  final String instructions;

  const PracticalUploadScreen({
    super.key,
    required this.microTopicId,
    required this.title,
    required this.instructions,
  });

  @override
  ConsumerState<PracticalUploadScreen> createState() =>
      _PracticalUploadScreenState();
}

class _PracticalUploadScreenState
    extends ConsumerState<PracticalUploadScreen> {
  _UploadState _state = _UploadState.idle;
  String? _pickedFileName;
  File? _pickedFile;
  String _feedbackMessage = '';
  int _xpEarned = 0;

  // ─── Pick the ZIP file ────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    setState(() => _state = _UploadState.picking);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      setState(() => _state = _UploadState.idle);
      return;
    }

    setState(() {
      _pickedFileName = result.files.single.name;
      _pickedFile = File(result.files.single.path!);
      _state = _UploadState.idle;
    });
  }

  // ─── Submit the ZIP to the Laravel Auto-Grader ────────────────────────────
  Future<void> _submitForGrading() async {
    if (_pickedFile == null) return;

    setState(() => _state = _UploadState.uploading);
    await Future.delayed(const Duration(milliseconds: 600)); // smooth UX
    setState(() => _state = _UploadState.grading);

    try {
      final dio = ref.read(apiClientProvider).dio;

      final formData = FormData.fromMap({
        'practical_file': await MultipartFile.fromFile(
          _pickedFile!.path,
          filename: _pickedFileName,
        ),
      });

      final response = await dio.post(
        '/v1/micro-topics/${widget.microTopicId}/attempt-practical',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data;

      if (response.statusCode == 200 && body['status'] == 'success') {
        final xpEarned = body['data']['xp_earned'] as int? ?? 50;
        ref.read(gamificationProvider.notifier).addXp(xpEarned);
        setState(() {
          _state = _UploadState.passed;
          _feedbackMessage = body['message'] ?? 'ප්‍රායෝගිකය සාර්ථකයි!';
          _xpEarned = xpEarned;
        });
      } else {
        ref.read(gamificationProvider.notifier).reduceHeart();
        setState(() {
          _state = _UploadState.failed;
          _feedbackMessage = body['message'] ?? 'ප්‍රායෝගිකය අසමත් විය.';
        });
      }
    } catch (e) {
      ref.read(gamificationProvider.notifier).reduceHeart();
      setState(() {
        _state = _UploadState.failed;
        _feedbackMessage =
            'Server connection error! Please check your network and retry.';
      });
    }
  }

  // ─── Reset to retry ───────────────────────────────────────────────────────
  void _reset() {
    setState(() {
      _state = _UploadState.idle;
      _pickedFile = null;
      _pickedFileName = null;
      _feedbackMessage = '';
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Full screen celebration on pass
    if (_state == _UploadState.passed) {
      return _buildResultScreen(passed: true);
    }
    // Full screen failure
    if (_state == _UploadState.failed) {
      return _buildResultScreen(passed: false);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Practical Badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.orange.shade700, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build_circle, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'PRACTICAL ASSESSMENT',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Instructions Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_outlined,
                            color: Colors.blueAccent, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Your Task',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.instructions,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Reward Chip ──
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 18),
                      SizedBox(width: 6),
                      Text(
                        '+50 XP on completion',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // ── File Picker Zone ──
              GestureDetector(
                onTap: _state == _UploadState.idle ? _pickFile : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 150,
                  decoration: BoxDecoration(
                    color: _pickedFile != null
                        ? Colors.green.withValues(alpha: 0.08)
                        : const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _pickedFile != null
                          ? Colors.green.shade600
                          : Colors.white24,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.check_circle_outline
                            : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _pickedFile != null
                            ? Colors.green
                            : Colors.white38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pickedFile != null
                            ? _pickedFileName!
                            : 'Tap to select your ZIP file',
                        style: TextStyle(
                          color: _pickedFile != null
                              ? Colors.green.shade300
                              : Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_pickedFile == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Only .zip files accepted',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Submit Button ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _state == _UploadState.uploading ||
                        _state == _UploadState.grading
                    ? _buildLoadingButton()
                    : _buildSubmitButton(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      key: const ValueKey('submit'),
      onPressed: _pickedFile != null ? _submitForGrading : null,
      icon: const Icon(Icons.send_rounded),
      label: const Text(
        'Submit for Auto-Grading',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white10,
        disabledForegroundColor: Colors.white30,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      key: const ValueKey('loading'),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
          ),
          const SizedBox(width: 14),
          Text(
            _state == _UploadState.uploading
                ? 'Uploading...'
                : '🤖 Auto-Grader is analyzing your files...',
            style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen({required bool passed}) {
    return Scaffold(
      backgroundColor: passed
          ? const Color(0xFF0A1F0A)
          : const Color(0xFF1A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lottie animation
              Lottie.network(
                passed
                    ? 'https://assets9.lottiefiles.com/packages/lf20_U10R4k.json'
                    : 'https://assets4.lottiefiles.com/packages/lf20_qp1q7mct.json',
                height: 200,
                errorBuilder: (context, error, stackTrace) => Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 100,
                  color: passed ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed ? '🎉 ශ්‍රේෂ්ඨ කාර්ය!' : '❌ නැවත උත්සාහ කරන්න',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),
              if (passed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Text(
                    '+$_xpEarned XP Earned!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 40),
              if (passed)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue Learning →',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Try Again',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

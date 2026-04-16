import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/assignment_provider.dart';
import '../../core/theme/app_theme.dart';
import 'dart:io';

class AssignmentScreen extends ConsumerStatefulWidget {
  final int assignmentId;
  final String title;

  const AssignmentScreen({super.key, required this.assignmentId, required this.title});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {
  File? _selectedFile;
  bool _isUploading = false;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _uploadAssignment() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    final success = await ref.read(assignmentUploaderProvider).submitAssignment(widget.assignmentId, _selectedFile!.path);

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Success! 🎉'),
            content: const Text('Your assignment has been submitted successfully for verification.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close Dialog
                  Navigator.of(context).pop(); // Go Back to Course Detail
                },
                child: const Text('Done'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please check the file size limits and try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncAssignment = ref.watch(assignmentDetailProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: AppTheme.textPrimaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: asyncAssignment.when(
        data: (assignment) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_turned_in, size: 80, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    assignment.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    assignment.description ?? "No specific instructions provided.",
                    style: const TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Due Date: ${assignment.dueDate != null ? DateTime.parse(assignment.dueDate!).toLocal().toString().split(' ')[0] : 'N/A'}",
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // File Upload Area
                  GestureDetector(
                    onTap: _isUploading ? null : _pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2, style: BorderStyle.values[1]), // Dash-like feel
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.file_present : Icons.cloud_upload_outlined,
                            size: 40,
                            color: _selectedFile != null ? Colors.green : AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _selectedFile != null 
                                  ? _selectedFile!.path.split('/').last 
                                  : "Tap to select a document\n(PDF, Word, or Image)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedFile != null ? Colors.green : AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_selectedFile != null)
                    ElevatedButton(
                      onPressed: _isUploading ? null : _uploadAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 24, height: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              "Submit Document", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                            ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load assignment details: $e')),
      ),
    );
  }
}

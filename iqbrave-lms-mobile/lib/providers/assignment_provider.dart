import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/assignment_model.dart';
import 'auth_provider.dart';

final assignmentDetailProvider = FutureProvider.family<AssignmentModel, int>((ref, id) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/assignments/$id');
  return AssignmentModel.fromJson(response.data['data']);
});

final assignmentUploaderProvider = Provider((ref) => AssignmentUploader(ref));

class AssignmentUploader {
  final Ref ref;
  AssignmentUploader(this.ref);

  Future<bool> submitAssignment(int assignmentId, String filePath) async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        '/assignments/$assignmentId/upload', 
        data: formData,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ASSIGNMENT UPLOAD ERROR: $e");
      return false;
    }
  }
}

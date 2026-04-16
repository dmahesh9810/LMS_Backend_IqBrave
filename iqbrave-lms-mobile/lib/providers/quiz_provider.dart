import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import 'auth_provider.dart';

final quizDetailProvider = FutureProvider.family<QuizModel, int>((ref, id) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/quizzes/$id');
  return QuizModel.fromJson(response.data['data']);
});

final quizUploaderProvider = Provider((ref) => QuizUploader(ref));

class QuizUploader {
  final Ref ref;
  QuizUploader(this.ref);

  Future<int?> submitQuiz(int quizId, List<Map<String, dynamic>> answers) async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.post('/quizzes/$quizId/submit', data: {
        'answers': answers,
      });
      return response.data['score'] as int?;
    } catch (e) {
      return null;
    }
  }
}

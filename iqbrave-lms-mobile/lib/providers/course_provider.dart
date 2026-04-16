import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import 'auth_provider.dart';

final coursesListProvider = FutureProvider<List<CourseModel>>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/courses');
  var list = response.data['data'] as List;
  return list.map((e) => CourseModel.fromJson(e)).toList();
});

final courseDetailProvider = FutureProvider.family<CourseModel, int>((ref, id) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/courses/$id');
  return CourseModel.fromJson(response.data['data']);
});

final lessonDetailProvider = FutureProvider.family<LessonModel, int>((ref, id) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/lessons/$id/materials');
  return LessonModel.fromJson(response.data['data']);
});

final learningPathProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/v1/learning-path');
  return response.data['data'];
});

/// Spaced Repetition: topics the student got wrong and should review today
final spacedRepetitionProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  try {
    final response = await dio.get('/v1/spaced-repetition/today');
    return response.data['data']['topics'] as List<dynamic>? ?? [];
  } catch (_) {
    return [];
  }
});

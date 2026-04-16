class QuizModel {
  final int id;
  final String title;
  final String? description;
  final int? timeLimitMinutes;
  final List<QuizQuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.timeLimitMinutes,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    return QuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      timeLimitMinutes: json['time_limit'],
      questions: rawQuestions.map((e) => QuizQuestionModel.fromJson(e)).toList(),
    );
  }
}

class QuizQuestionModel {
  final int id;
  final String questionText;
  final int marks;
  final List<QuizOptionModel> options;

  QuizQuestionModel({
    required this.id,
    required this.questionText,
    this.marks = 1,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List? ?? [];
    return QuizQuestionModel(
      id: json['id'],
      questionText: json['question_text'],
      marks: json['marks'] ?? 1,
      options: rawOptions.map((e) => QuizOptionModel.fromJson(e)).toList(),
    );
  }
}

class QuizOptionModel {
  final int id;
  final String optionText;

  QuizOptionModel({required this.id, required this.optionText});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'],
      optionText: json['option_text'],
    );
  }
}

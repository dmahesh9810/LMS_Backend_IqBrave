class CourseModel {
  final int id;
  final String title;
  final String description;
  final String? status;
  final List<CourseModule> modules;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.status,
    this.modules = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    var rawModules = json['modules'] as List?;
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      modules: rawModules != null 
          ? rawModules.map((e) => CourseModule.fromJson(e)).toList() 
          : [],
    );
  }
}

class CourseModule {
  final int id;
  final String title;
  final List<CourseUnit> units;

  CourseModule({required this.id, required this.title, this.units = const []});

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    var rawUnits = json['units'] as List?;
    return CourseModule(
      id: json['id'],
      title: json['title'],
      units: rawUnits != null 
          ? rawUnits.map((e) => CourseUnit.fromJson(e)).toList() 
          : [],
    );
  }
}

class CourseUnit {
  final int id;
  final String title;
  final List<LessonModel> lessons;
  final List<CourseQuizModel> quizzes;
  final List<CourseAssignmentModel> assignments;

  CourseUnit({
    required this.id, 
    required this.title, 
    this.lessons = const [], 
    this.quizzes = const [],
    this.assignments = const [],
  });

  factory CourseUnit.fromJson(Map<String, dynamic> json) {
    var rawLessons = json['lessons'] as List?;
    var rawQuizzes = json['quizzes'] as List?;
    var rawAssignments = json['assignments'] as List?;
    return CourseUnit(
      id: json['id'],
      title: json['title'],
      lessons: rawLessons != null 
          ? rawLessons.map((e) => LessonModel.fromJson(e)).toList() 
          : [],
      quizzes: rawQuizzes != null 
          ? rawQuizzes.map((e) => CourseQuizModel.fromJson(e)).toList() 
          : [],
      assignments: rawAssignments != null 
          ? rawAssignments.map((e) => CourseAssignmentModel.fromJson(e)).toList() 
          : [],
    );
  }
}

class CourseQuizModel {
  final int id;
  final String title;

  CourseQuizModel({required this.id, required this.title});

  factory CourseQuizModel.fromJson(Map<String, dynamic> json) {
    return CourseQuizModel(id: json['id'], title: json['title']);
  }
}

class CourseAssignmentModel {
  final int id;
  final String title;

  CourseAssignmentModel({required this.id, required this.title});

  factory CourseAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CourseAssignmentModel(id: json['id'], title: json['title']);
  }
}

class LessonModel {
  final int id;
  final String title;
  final String? content;
  final String? videoUrl;
  final String? documentUrl;

  LessonModel({required this.id, required this.title, this.content, this.videoUrl, this.documentUrl});

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      videoUrl: json['video_url'],
      documentUrl: json['document_url'],
    );
  }
}

class AssignmentModel {
  final int id;
  final String title;
  final String? description;
  final String? dueDate;
  final int maxMarks;

  AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.maxMarks = 100,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'],
      maxMarks: json['max_marks'] ?? 100,
    );
  }
}

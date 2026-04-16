class RadarData {
  final List<String> labels;
  final List<double> data;

  RadarData({required this.labels, required this.data});

  factory RadarData.fromJson(Map<String, dynamic> json) {
    var rawLabels = json['labels'] as List;
    var rawData = json['data'] as List;
    return RadarData(
      labels: rawLabels.map((e) => e.toString()).toList(),
      data: rawData.map((e) => double.parse(e.toString())).toList(),
    );
  }
}

class WeaknessData {
  final int id;
  final double score;
  final String topicName;

  WeaknessData({required this.id, required this.score, required this.topicName});

  factory WeaknessData.fromJson(Map<String, dynamic> json) {
    return WeaknessData(
      id: json['id'],
      score: double.parse(json['mastery_percentage'].toString()),
      topicName: json['micro_topic']['topic_name'],
    );
  }
}

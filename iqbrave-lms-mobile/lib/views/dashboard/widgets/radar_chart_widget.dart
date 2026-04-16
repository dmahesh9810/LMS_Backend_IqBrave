import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/knowledge_model.dart';
import '../../../core/theme/app_theme.dart';

class RadarChartWidget extends StatelessWidget {
  final RadarData data;

  const RadarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.labels.isEmpty) {
      return const Center(child: Text("Not enough data to map knowledge. Take some quizzes!"));
    }

    List<String> labels = List.from(data.labels);
    List<double> scores = List.from(data.data);

    // FL Chart Radar requires at least 3 points to draw a polygon.
    while (labels.length < 3) {
      labels.add("");
      scores.add(0.0);
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppTheme.primaryColor.withOpacity(0.4),
              borderColor: AppTheme.primaryColor,
              entryRadius: 3,
              dataEntries: scores.map((val) => RadarEntry(value: val)).toList(),
              borderWidth: 2,
            )
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.black12, width: 2),
          titlePositionPercentageOffset: 0.1,
          titleTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: labels[index],
              angle: 0,
            );
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          tickBorderData: const BorderSide(color: Colors.black12),
          gridBorderData: const BorderSide(color: Colors.black12, width: 2),
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

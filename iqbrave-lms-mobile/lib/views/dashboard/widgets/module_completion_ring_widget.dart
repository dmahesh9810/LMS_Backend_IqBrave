import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/course_provider.dart';

/// Shows module completion as a donut ring (fl_chart) + stats below
class ModuleCompletionRingWidget extends ConsumerWidget {
  const ModuleCompletionRingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(learningPathProvider);

    return pathAsync.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (pathData) {
        final nodes = pathData['nodes'] as List<dynamic>? ?? [];
        final total     = nodes.length;
        final completed = nodes.where((n) => n['status'] == 'completed').length;
        final locked    = nodes.where((n) => n['status'] == 'locked').length;
        final active    = total - completed - locked;
        final percent   = total > 0 ? (completed / total * 100).round() : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.donut_large_rounded, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'M01 Module Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Donut chart
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              PieChartSectionData(
                                value: completed.toDouble().clamp(0.001, double.infinity),
                                color: const Color(0xFF22C55E),
                                radius: 18,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: active.toDouble().clamp(0.001, double.infinity),
                                color: const Color(0xFF3B82F6),
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: locked.toDouble().clamp(0.001, double.infinity),
                                color: Colors.white10,
                                radius: 10,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        // Center percent text
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: const Color(0xFF22C55E), label: 'Completed', count: completed),
                        const SizedBox(height: 8),
                        _LegendItem(color: const Color(0xFF3B82F6), label: 'In Progress', count: active),
                        const SizedBox(height: 8),
                        _LegendItem(color: Colors.white24, label: 'Locked', count: locked),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Linear progress below
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFF22C55E),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$completed of $total nodes completed',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

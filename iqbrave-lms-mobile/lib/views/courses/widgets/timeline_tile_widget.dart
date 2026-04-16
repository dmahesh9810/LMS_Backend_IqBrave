import 'package:flutter/material.dart';

// ── Node Status from API ───────────────────────────────────────────────────
enum NodeStatus { completed, active, locked }

// ── Node Type from API ─────────────────────────────────────────────────────
enum TimelineNodeType { lesson, quiz, assignment, practical }

class TimelineNodeData {
  final int id;
  final String title;
  final TimelineNodeType type;
  final NodeStatus status;
  final int stars;

  TimelineNodeData({
    required this.id,
    required this.title,
    required this.type,
    this.status = NodeStatus.active,
    this.stars = 0,
  });
}

class TimelineTileWidget extends StatelessWidget {
  final TimelineNodeData node;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const TimelineTileWidget({
    super.key,
    required this.node,
    this.isFirst = false,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Visual states based on status ──────────────────────────────────────
    final isCompleted = node.status == NodeStatus.completed;
    final isLocked    = node.status == NodeStatus.locked;

    // Node Icon
    IconData iconData;
    switch (node.type) {
      case TimelineNodeType.practical:
        iconData = isCompleted ? Icons.build_circle : Icons.build_circle_outlined;
        break;
      case TimelineNodeType.quiz:
        iconData = isCompleted ? Icons.check_circle : Icons.help_outline;
        break;
      case TimelineNodeType.assignment:
        iconData = Icons.upload_file;
        break;
      case TimelineNodeType.lesson:
        iconData = isCompleted ? Icons.check_circle : Icons.stars_rounded;
        break;
    }

    // Colors
    Color nodeColor;
    if (isCompleted) {
      nodeColor = const Color(0xFF22C55E); // Green
    } else if (isLocked) {
      nodeColor = Colors.grey.shade400;    // Grey
    } else {
      // active
      nodeColor = node.type == TimelineNodeType.practical
          ? Colors.orange
          : const Color(0xFF3B82F6);  // Blue
    }

    // Card background
    Color cardBg;
    Color cardBorder;
    if (isCompleted) {
      cardBg     = const Color(0xFF0A1F0A);
      cardBorder = const Color(0xFF22C55E).withValues(alpha: 0.4);
    } else if (isLocked) {
      cardBg     = const Color(0xFF1A1A2E);
      cardBorder = Colors.white10;
    } else {
      cardBg     = const Color(0xFF161B22);
      cardBorder = nodeColor.withValues(alpha: 0.5);
    }

    // Subtitle
    String subtitle;
    if (isCompleted) {
      subtitle = '✅ Completed  ${node.stars > 0 ? '⭐' * node.stars : ''}';
    } else if (isLocked) {
      subtitle = '🔒 Complete previous node first';
    } else if (node.type == TimelineNodeType.practical) {
      subtitle = '⚙️ Practical Task  •  +50 XP';
    } else {
      subtitle = '📖 Tap to start  •  +10 XP';
    }

    // Line color for the connector
    final lineColor = isCompleted
        ? const Color(0xFF22C55E).withValues(alpha: 0.6)
        : Colors.white10;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline connector + node dot ──────────────────────────────
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : lineColor,
                  ),
                ),
                // The Node circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: nodeColor.withValues(alpha: isLocked ? 0.08 : 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: nodeColor,
                      width: isLocked ? 1.5 : 2.5,
                    ),
                    boxShadow: isLocked
                        ? null
                        : [
                            BoxShadow(
                              color: nodeColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                  ),
                  child: Icon(iconData, size: 18, color: nodeColor),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Content Card ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: isLocked ? null : onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder, width: 1.5),
                    boxShadow: isLocked
                        ? null
                        : [
                            BoxShadow(
                              color: nodeColor.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              node.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isLocked
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLocked
                                    ? Colors.white24
                                    : nodeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isLocked
                            ? Icons.lock_outline
                            : isCompleted
                                ? Icons.check_circle
                                : Icons.arrow_forward_ios,
                        size: isCompleted ? 22 : 14,
                        color: isLocked
                            ? Colors.white24
                            : nodeColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

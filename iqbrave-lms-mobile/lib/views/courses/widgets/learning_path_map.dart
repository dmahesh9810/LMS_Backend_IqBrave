import 'package:flutter/material.dart';
import 'dart:math' as math;

class LearningPathMap extends StatelessWidget {
  final List<dynamic> nodes;
  final void Function(dynamic node) onNodeTap;
  /// Phase 6: mastery map — micro_topic_id → mastery data
  final Map<int, Map<String, dynamic>> masteryMap;

  const LearningPathMap({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.masteryMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        // Render from bottom to top for winding effect
        final node   = nodes[nodes.length - 1 - index];
        final isLeft = index % 2 == 0;
        final nodeId = node['id'] as int? ?? 0;
        final mastery = masteryMap[nodeId];

        return Padding(
          padding: const EdgeInsets.only(bottom: 28.0),
          child: Row(
            mainAxisAlignment:
                isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isLeft) const SizedBox(width: 60),
              GestureDetector(
                onTap: () => onNodeTap(node),
                child: _buildNode(node, index, mastery),
              ),
              if (!isLeft) const SizedBox(width: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNode(dynamic node, int index, Map<String, dynamic>? mastery) {
    final String status     = node['status'] ?? 'locked';
    final bool isPractical  = node['is_practical'] == true || node['type'] == 'practical';
    final int stars         = (node['stars'] ?? 0) as int;
    final int masteryScore  = mastery?['mastery_score'] as int? ?? 0;
    final String masteryLevel = mastery?['mastery_level'] as String? ?? 'struggling';
    final bool isMastered   = masteryScore >= 80;

    // ── Colors per status ──────────────────────────────────────────────
    Color bgColor, glowColor, borderColor, iconColor;
    IconData iconData;

    if (status == 'completed') {
      bgColor     = const Color(0xFF16A34A);
      glowColor   = const Color(0xFF22C55E);
      borderColor = const Color(0xFF4ADE80);
      iconColor   = Colors.white;
      iconData    = Icons.star_rounded;
    } else if (status == 'active') {
      if (isPractical) {
        bgColor     = const Color(0xFFC2410C);
        glowColor   = Colors.orange;
        borderColor = Colors.orange.shade300;
        iconColor   = Colors.white;
        iconData    = Icons.build_rounded;
      } else {
        bgColor     = const Color(0xFF1D4ED8);
        glowColor   = const Color(0xFF3B82F6);
        borderColor = const Color(0xFF93C5FD);
        iconColor   = Colors.white;
        iconData    = Icons.play_arrow_rounded;
      }
    } else {
      bgColor     = const Color(0xFF1E293B);
      glowColor   = Colors.transparent;
      borderColor = const Color(0xFF334155);
      iconColor   = Colors.white24;
      iconData    = Icons.lock_rounded;
    }

    // ── Mastery ring colour ────────────────────────────────────────────
    Color masteryRingColor = Colors.transparent;
    if (mastery != null && status == 'completed') {
      masteryRingColor = isMastered
          ? const Color(0xFF22C55E)   // 🟢 mastered
          : masteryLevel == 'learning'
              ? Colors.amber          // 🟡 learning
              : Colors.redAccent;     // 🔴 struggling
    }

    return Column(
      children: [
        //── Node Circle ────────────────────────────────────────────────
        Stack(
          alignment: Alignment.center,
          children: [
            // 🟢🟡🔴 Mastery arc ring (Phase 6)
            if (mastery != null && status == 'completed')
              SizedBox(
                width: 104,
                height: 104,
                child: CustomPaint(
                  painter: _MasteryArcPainter(
                    score: masteryScore,
                    color: masteryRingColor,
                  ),
                ),
              ),

            // Ambient glow
            if (status != 'locked')
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor.withValues(alpha: 0.18),
                ),
              ),

            // Main circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor, width: 3.5),
                boxShadow: status == 'locked'
                    ? null
                    : [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Center(
                child: isMastered && status == 'completed'
                    ? const Text('🏆', style: TextStyle(fontSize: 32))
                    : Icon(iconData, color: iconColor, size: 38),
              ),
            ),

            // Stars badge
            if (status == 'completed' && stars > 0)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300, width: 1),
                  ),
                  child: const Text('⭐', style: TextStyle(fontSize: 12)),
                ),
              ),

            // Mastery score badge (top-right, Phase 6)
            if (mastery != null && status == 'completed')
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: masteryRingColor,
                    border: Border.all(color: Colors.black54, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$masteryScore',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        //── Node Label ─────────────────────────────────────────────────
        SizedBox(
          width: 110,
          child: Text(
            node['title'] ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: status == 'locked' ? Colors.white24 : Colors.white70,
            ),
          ),
        ),

        const SizedBox(height: 4),

        //── Status / Mastery Label ─────────────────────────────────────
        Text(
          status == 'completed'
              ? isMastered
                  ? '🏆 Mastered!'
                  : masteryLevel == 'learning'
                      ? '🟡 $masteryScore% mastery'
                      : '🔴 $masteryScore% mastery'
              : status == 'active'
                  ? isPractical ? '⚙️ Practical' : '▶️ Start'
                  : '🔒 Locked',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: status == 'completed'
                ? isMastered ? const Color(0xFF4ADE80) : Colors.amber
                : status == 'active'
                    ? glowColor
                    : Colors.white12,
          ),
        ),
      ],
    );
  }
}

/// Custom arc painter for mastery ring around the node
class _MasteryArcPainter extends CustomPainter {
  final int score;
  final Color color;

  _MasteryArcPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep  = 2 * math.pi;
    final sweepAngle = fullSweep * (score / 100);

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, paint,
    );
  }

  @override
  bool shouldRepaint(_MasteryArcPainter old) =>
      old.score != score || old.color != color;
}

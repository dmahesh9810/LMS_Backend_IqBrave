import 'package:flutter/material.dart';

class LearningPathMap extends StatelessWidget {
  final List<dynamic> nodes;
  final void Function(dynamic node) onNodeTap;

  const LearningPathMap({super.key, required this.nodes, required this.onNodeTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        // Render from bottom to top for winding effect
        final node = nodes[nodes.length - 1 - index];
        final isLeft = index % 2 == 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 28.0),
          child: Row(
            mainAxisAlignment:
                isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isLeft) const SizedBox(width: 60),
              GestureDetector(
                onTap: () => onNodeTap(node),
                child: _buildNode(node, index),
              ),
              if (!isLeft) const SizedBox(width: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNode(dynamic node, int index) {
    final String status = node['status'] ?? 'locked';
    final bool isPractical = node['is_practical'] == true || node['type'] == 'practical';
    final int stars = (node['stars'] ?? 0) as int;

    // ── Colors per status ──────────────────────────────────────────────
    Color bgColor;
    Color glowColor;
    Color borderColor;
    Color iconColor;
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
      // locked
      bgColor     = const Color(0xFF1E293B);
      glowColor   = Colors.transparent;
      borderColor = const Color(0xFF334155);
      iconColor   = Colors.white24;
      iconData    = Icons.lock_rounded;
    }

    return Column(
      children: [
        // ── Node Circle ───────────────────────────────────────────────
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring for active/completed
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
                child: Icon(iconData, color: iconColor, size: 38),
              ),
            ),
            // Stars badge for completed
            if (status == 'completed' && stars > 0)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300, width: 1),
                  ),
                  child: Text(
                    '⭐',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Node Label ────────────────────────────────────────────────
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

        // ── Status Label ──────────────────────────────────────────────
        const SizedBox(height: 4),
        Text(
          status == 'completed'
              ? '✅ Done'
              : status == 'active'
                  ? isPractical ? '⚙️ Practical' : '▶️ Start'
                  : '🔒 Locked',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: status == 'completed'
                ? const Color(0xFF4ADE80)
                : status == 'active'
                    ? glowColor
                    : Colors.white12,
          ),
        ),
      ],
    );
  }
}

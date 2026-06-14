import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

// ── Provider ──────────────────────────────────────────────────────────────
final badgesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  try {
    final response = await dio.get('/v1/student/badges');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

// ── Badge Unlock Popup (shown immediately after earning) ──────────────────
Future<void> showBadgeUnlock(
  BuildContext context,
  List<Map<String, dynamic>> newBadges,
) async {
  if (newBadges.isEmpty) return;

  for (final badge in newBadges) {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Badge',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: child,
      ),
      pageBuilder: (ctx, a1, a2) => _BadgeUnlockDialog(badge: badge),
    );
  }
}

class _BadgeUnlockDialog extends StatelessWidget {
  final Map<String, dynamic> badge;
  const _BadgeUnlockDialog({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF6366F1), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✨ Sparkle header
              const Text(
                '✨ Badge Unlocked!',
                style: TextStyle(
                  color: Color(0xFFA5B4FC),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Badge emoji (large)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF4338CA), Color(0xFF1E1B4B)],
                  ),
                  border: Border.all(color: const Color(0xFF818CF8), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badge['emoji'] ?? '🏅',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Badge name
              Text(
                badge['name'] ?? 'Badge Earned',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Badge description
              Text(
                badge['description'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC7D2FE),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Awesome! 🎉',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

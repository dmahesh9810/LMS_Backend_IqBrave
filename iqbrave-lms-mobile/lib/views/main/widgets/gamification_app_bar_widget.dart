import 'package:flutter/material.dart';

class GamificationAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final int streakDays;
  final int xp;
  final int hearts;

  const GamificationAppBarWidget({
    super.key,
    this.streakDays = 0,
    this.xp = 0,
    this.hearts = 5,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.shade300,
          height: 1.0,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Course indicator (Flag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Text('🇱🇰', style: TextStyle(fontSize: 18)), // Si
              ],
            ),
          ),
          
          // Streak
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '$streakDays',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // XP / Gems
          Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '$xp',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Hearts
          Row(
            children: [
              const Text('❤️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                '$hearts',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

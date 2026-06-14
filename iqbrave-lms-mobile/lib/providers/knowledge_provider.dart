import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/knowledge_model.dart';
import 'auth_provider.dart';

final radarDataProvider = FutureProvider<RadarData>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/student/knowledge-radar');
  return RadarData.fromJson(response.data['chart']);
});

final weaknessesProvider = FutureProvider<List<WeaknessData>>((ref) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/student/weaknesses');
  var list = response.data['data'] as List;
  return list.map((e) => WeaknessData.fromJson(e)).toList();
});

class GamificationState {
  final int xp;
  final int hearts;
  final int currentStreak;
  // Phase 7B: Level info
  final int level;
  final String levelTitle;
  final String levelEmoji;
  final String? levelPerk;
  final int xpToNext;
  final int levelProgress; // 0-100%
  // Phase 7C: Streak Shield
  final bool streakShieldActive;
  // Phase 7D: Daily Goal
  final int dailyGoal;
  final int dailyNodesToday;

  GamificationState({
    this.xp = 0,
    this.hearts = 5,
    this.currentStreak = 0,
    this.level = 1,
    this.levelTitle = 'Beginner',
    this.levelEmoji = '🌱',
    this.levelPerk,
    this.xpToNext = 100,
    this.levelProgress = 0,
    this.streakShieldActive = false,
    this.dailyGoal = 3,
    this.dailyNodesToday = 0,
  });

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      xp:                  json['xp'] ?? 0,
      hearts:              json['hearts'] ?? 5,
      currentStreak:       json['current_streak'] ?? 0,
      level:               json['level'] ?? 1,
      levelTitle:          json['level_title'] ?? 'Beginner',
      levelEmoji:          json['level_emoji'] ?? '🌱',
      levelPerk:           json['level_perk'],
      xpToNext:            json['xp_to_next'] ?? 100,
      levelProgress:       json['level_progress'] ?? 0,
      streakShieldActive:  json['streak_shield_active'] == true,
      dailyGoal:           json['daily_goal'] ?? 3,
      dailyNodesToday:     json['daily_nodes_today'] ?? 0,
    );
  }

  GamificationState copyWith({
    int? xp, int? hearts, int? currentStreak,
    int? level, String? levelTitle, String? levelEmoji,
    String? levelPerk, int? xpToNext, int? levelProgress,
    bool? streakShieldActive, int? dailyGoal, int? dailyNodesToday,
  }) {
    return GamificationState(
      xp:                 xp ?? this.xp,
      hearts:             hearts ?? this.hearts,
      currentStreak:      currentStreak ?? this.currentStreak,
      level:              level ?? this.level,
      levelTitle:         levelTitle ?? this.levelTitle,
      levelEmoji:         levelEmoji ?? this.levelEmoji,
      levelPerk:          levelPerk ?? this.levelPerk,
      xpToNext:           xpToNext ?? this.xpToNext,
      levelProgress:      levelProgress ?? this.levelProgress,
      streakShieldActive: streakShieldActive ?? this.streakShieldActive,
      dailyGoal:          dailyGoal ?? this.dailyGoal,
      dailyNodesToday:    dailyNodesToday ?? this.dailyNodesToday,
    );
  }
}

class GamificationNotifier extends AsyncNotifier<GamificationState> {
  @override
  FutureOr<GamificationState> build() async {
    final dio = ref.read(apiClientProvider).dio;
    final response = await dio.get('/v1/gamification/status');
    final data = response.data['data'];
    return GamificationState.fromJson(data);
  }

  void reduceHeart() {
    state.whenData((current) {
      if (current.hearts > 0) {
        state = AsyncValue.data(current.copyWith(hearts: current.hearts - 1));
      }
    });
  }

  void addXp(int amount) {
    state.whenData((current) {
      state = AsyncValue.data(current.copyWith(xp: current.xp + amount));
    });
  }
}

final gamificationProvider = AsyncNotifierProvider<GamificationNotifier, GamificationState>(() {
  return GamificationNotifier();
});

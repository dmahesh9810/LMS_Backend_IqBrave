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

  GamificationState({this.xp = 0, this.hearts = 5, this.currentStreak = 0});

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      xp: json['xp'] ?? 0,
      hearts: json['hearts'] ?? 5,
      currentStreak: json['current_streak'] ?? 0,
    );
  }

  GamificationState copyWith({int? xp, int? hearts, int? currentStreak}) {
    return GamificationState(
      xp: xp ?? this.xp,
      hearts: hearts ?? this.hearts,
      currentStreak: currentStreak ?? this.currentStreak,
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

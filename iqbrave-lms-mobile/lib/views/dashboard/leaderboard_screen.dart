import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isLoading = true;
  List<dynamic> _leaderboard = [];
  Map<String, dynamic>? _currentUserRank;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get('/v1/leaderboard');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          _leaderboard = data['leaderboard'] ?? [];
          _currentUserRank = data['current_user'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Global Leaderboard 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final item = _leaderboard[index];
                      return _buildLeaderboardTile(item, isCurrentUser: false);
                    },
                  ),
                ),
                if (_currentUserRank != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: const Color(0xFF1E293B),
                    child: Column(
                      children: [
                        const Text('Your Current Rank', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLeaderboardTile(_currentUserRank!, isCurrentUser: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> item, {required bool isCurrentUser}) {
    final int rank = item['rank'];
    final String name = item['name'];
    final int xp = item['xp'];
    final String levelTitle = item['level_title'] ?? 'Novice';

    Color rankColor;
    Widget rankWidget;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankWidget = const Icon(Icons.workspace_premium, color: Colors.amber, size: 30);
    } else if (rank == 2) {
      rankColor = Colors.grey.shade300;
      rankWidget = Icon(Icons.workspace_premium, color: Colors.grey.shade300, size: 30);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankWidget = const Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 30);
    } else {
      rankColor = Colors.blueAccent;
      rankWidget = Text(
        '#$rank',
        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? Colors.blueAccent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 40,
          child: Center(child: rankWidget),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          levelTitle,
          style: TextStyle(color: rankColor, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$xp',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
            ),
            const Text(
              'XP',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

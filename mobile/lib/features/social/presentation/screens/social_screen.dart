import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFD4AF37),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Village Citizen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Level 1 • 0 XP',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.0,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _LeaderboardTile(
                    rank: 1,
                    name: 'Trading Master',
                    level: 'Kingdom',
                    xp: 15420,
                    isCurrentUser: false,
                  ),
                  _LeaderboardTile(
                    rank: 2,
                    name: 'Crypto Queen',
                    level: 'City',
                    xp: 12380,
                    isCurrentUser: false,
                  ),
                  _LeaderboardTile(
                    rank: 3,
                    name: 'Portfolio Prince',
                    level: 'City',
                    xp: 9850,
                    isCurrentUser: false,
                  ),
                  _LeaderboardTile(
                    rank: 847,
                    name: 'You',
                    level: 'Village',
                    xp: 0,
                    isCurrentUser: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final String level;
  final int xp;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.level,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    Color? tileColor = isCurrentUser ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : null;
    
    return Card(
      color: tileColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text('$level • ${xp.toStringAsFixed(0)} XP'),
        trailing: Icon(
          _getLevelIcon(),
          color: const Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF6B7280); // Gray
  }

  IconData _getLevelIcon() {
    switch (level) {
      case 'Kingdom':
        return Icons.castle;
      case 'City':
        return Icons.location_city;
      case 'Town':
        return Icons.home;
      default:
        return Icons.cottage;
    }
  }
}
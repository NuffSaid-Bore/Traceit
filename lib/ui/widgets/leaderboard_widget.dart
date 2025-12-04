import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/models/leaderboard_mode.dart';
import 'package:trace_it/models/leaderboard_user.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  String medal(int i) {
    if (i == 0) return "🥇";
    if (i == 1) return "🥈";
    if (i == 2) return "🥉";
    return "";
  }

  Color medalColor(int i) {
    if (i == 0) return const Color(0xFFFFD700); // Gold
    if (i == 1) return const Color(0xFFC0C0C0); // Silver
    if (i == 2) return const Color(0xFFCD7F32); // Bronze
    return Colors.white.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (_, provider, __) {
        final entries = provider.entries;

        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TABS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tab(context, provider, LeaderboardMode.global, "Global"),
                _tab(context, provider, LeaderboardMode.weekly, "Weekly"),
                _tab(context, provider, LeaderboardMode.monthly, "Monthly"),
              ],
            ),

            const SizedBox(height: 20),

            // ===== LIST =====
            AnimatedList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: entries.length,
              itemBuilder: (_, i, anim) {
                final e = entries[i];
                int oldRank = e.previousRank;
                int newRank = i;

                bool movedUp = oldRank > newRank;
                bool movedDown = oldRank < newRank;

                Offset offset = movedUp
                    ? const Offset(0, 0.3) 
                    : movedDown
                    ? const Offset(0, -0.3) 
                    : Offset.zero;

                return AnimatedSlide(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  offset: offset,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: e.previousRank == i
                        ? 1.0
                        : 1.0, // fade only if you want
                    child: _buildCard(i, e),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(int rank, LeaderboardEntry e) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            "#${rank + 1} ${medal(rank)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: medalColor(rank),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.deepPurple,
            child: Text(
              e.username.isNotEmpty ? e.username[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e.username,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Text(
            e.score.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ===== TAB WIDGET =====
  Widget _tab(
    BuildContext context,
    LeaderboardProvider provider,
    LeaderboardMode mode,
    String label,
  ) {
    final bool selected = provider.mode == mode;

    return GestureDetector(
      onTap: () => provider.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurpleAccent.withOpacity(0.7) : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

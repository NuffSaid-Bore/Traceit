import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (_, provider, __) {
        // Show simple loading placeholder
        if (provider.entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Loading leaderboard...",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          );
        }

        final topEntries = provider.entries.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            for (int i = 0; i < topEntries.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rank with emoji
                    Text(
                      i == 0
                          ? "#1 🥇"
                          : i == 1
                          ? "#2 🥈"
                          : i == 2
                          ? "#3 🥉"
                          : "#${i + 1}", // normal numbers for others
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: i < 3 ? Colors.white : Colors.white70,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Username
                    Expanded(
                      child: Text(
                        topEntries[i].username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Score
                    Text(
                      topEntries[i].score.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

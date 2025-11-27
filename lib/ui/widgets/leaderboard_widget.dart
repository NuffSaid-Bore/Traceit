import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (_, provider, __) {
        final topEntries = provider.top(10);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < topEntries.length; i++)
              ListTile(
                leading: Text(
                  "#${i + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: i < 3
                        ? (i == 0
                            ? Colors.amber
                            : i == 1
                                ? Colors.grey
                                : Colors.brown)
                        : Colors.black,
                  ),
                ),
                title: Text(topEntries[i].username),
                trailing: Text(
                  topEntries[i].score.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}

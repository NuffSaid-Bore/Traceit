import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/badge_provider.dart';
import '../../models/badge.dart';

class BadgeTimeline extends StatelessWidget {
  const BadgeTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeProvider = Provider.of<BadgeProvider>(context);

    // Static list of badge definitions (visuals only)
    final List<Badges> badgeDefinitions = [
      Badges(
        type: BadgeType.daily3,
        title: "3-Day Streak",
        description: "Play 3 consecutive days",
        icon: Icons.looks_one,
      ),
      Badges(
        type: BadgeType.daily5,
        title: "5-Day Streak",
        description: "Play 5 consecutive days",
        icon: Icons.looks_two,
      ),
      Badges(
        type: BadgeType.daily10,
        title: "10-Day Streak",
        description: "Play 10 consecutive days",
        icon: Icons.looks_3,
      ),
      Badges(
        type: BadgeType.daily30,
        title: "30-Day Streak",
        description: "Play 30 consecutive days",
        icon: Icons.star,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: badgeDefinitions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            Badges badge = badgeDefinitions[index];
      
            // Firestore: earnedBadges["daily3"] etc
            bool earned = badgeProvider.earned[badge.type.name] ?? false;
      
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: earned ? Colors.amber : Colors.grey,
                  child: Icon(badge.icon, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: earned ? Colors.amber : Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

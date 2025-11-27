import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/badge_provider.dart';
import '../../models/badge.dart';

class BadgeTimeline extends StatelessWidget {
  const BadgeTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeProvider = Provider.of<BadgeProvider>(context);

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badgeProvider.badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          Badges badge = badgeProvider.badges[index];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: badge.earned ? Colors.amber : Colors.grey,
                child: Icon(badge.icon, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                badge.title,
                style: TextStyle(
                  fontSize: 12,
                  color: badge.earned ? Colors.amber : Colors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

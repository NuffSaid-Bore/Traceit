import 'package:flutter/material.dart';

enum BadgeType { daily3, daily5, daily10, daily30 }

class Badges {
  final BadgeType type;
  final String title;
  final String description;
  final IconData icon;
  final bool earned;
  final DateTime? earnedDate;

  Badges({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.earned = false,
    this.earnedDate,
  });

  Badges copyWith({
    bool? earned,
    DateTime? earnedDate,
  }) {
    return Badges(
      type: type,
      title: title,
      description: description,
      icon: icon,
      earned: earned ?? this.earned,
      earnedDate: earnedDate ?? this.earnedDate,
    );
  }
}


// final List<Badge> badges = [
//   Badge(
//     type: BadgeType.daily3,
//     title: '3 Days in a Row',
//     description: 'You have completed 3 days in a row!',
//     icon: Icons.star,
//   ),
//   Badge(
//     type: BadgeType.daily5,
//     title: '5 Days in a Row',
//     description: 'You have completed 5 days in a row!',
//     icon: Icons.star,
//   ),
//   Badge(
//     type: BadgeType.daily10,
//     title: '10 Days in a Row',
//     description: 'You have completed 10 days in a row!',
//     icon: Icons.star,
//   ),
//   Badge(
//     type: BadgeType.daily30,
//     title: '30 Days in a Row',
//     description: 'You have completed 30 days in a row!',
//     icon: Icons.star,
//   ),
// ];
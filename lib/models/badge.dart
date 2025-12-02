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

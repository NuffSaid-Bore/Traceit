
import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../core/utils/streak_utils.dart';

class BadgeProvider extends ChangeNotifier {
  List<Badges> _badges = [
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

  List<DateTime> _activityDates = []; // could be loaded from Hive

  List<Badges> get badges => _badges;

  int get currentStreak => StreakUtils.calculateStreak(_activityDates);

  void addActivity(DateTime date) {
    _activityDates.add(date);

    _updateBadges();
    notifyListeners();
  }

  void _updateBadges() {
    int streak = currentStreak;

    _badges = _badges.map((b) {
      bool earnedNow = false;
      switch (b.type) {
        case BadgeType.daily3:
          earnedNow = streak >= 3;
          break;
        case BadgeType.daily5:
          earnedNow = streak >= 5;
          break;
        case BadgeType.daily10:
          earnedNow = streak >= 10;
          break;
        case BadgeType.daily30:
          earnedNow = streak >= 30;
          break;
      }

      return b.copyWith(
        earned: earnedNow,
        earnedDate: earnedNow ? DateTime.now() : b.earnedDate,
      );
    }).toList();
  }
}

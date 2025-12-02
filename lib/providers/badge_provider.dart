import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../core/utils/streak_utils.dart';
import '../core/services/firestore_service.dart';

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

  List<DateTime> _activityDates = []; // loaded from Firestore

  List<Badges> get badges => _badges;

  Map<String, bool> earned = {};
  int dailyStreak = 0;

  int get currentStreak => StreakUtils.calculateStreak(_activityDates);

  /// Load activity from Firestore
  Future<void> loadBadgesAndStreak() async {
    _activityDates = await FirestoreService.loadUserActivityDates() ?? [];
    _updateBadges();
    notifyListeners();
  }

  /// Add activity (e.g., puzzle completed)
  Future<void> addActivity(DateTime date) async {
    _activityDates.add(date);

    await FirestoreService.saveUserActivityDate(date);
    _updateBadges();
    notifyListeners();
  }

  /// Update badges and daily streak from Firestore data
  void updateFromFirestore(Map<String, dynamic> data) {
    dailyStreak = data['dailyStreak'] ?? 0;
    earned = Map<String, bool>.from(data['earnedBadges'] ?? {});
    notifyListeners();
  }

  /// Reset streak if user resets game or increases attempts
  Future<void> resetStreak() async {
    _activityDates.clear();
    await FirestoreService.clearUserActivityDates();
    _updateBadges();
    notifyListeners();
  }

  /// Update badges based on streak
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

      // update earned map for BadgeTimeline
      earned[b.type.name] = earnedNow;

      return b.copyWith(
        earned: earnedNow,
        earnedDate: earnedNow ? DateTime.now() : b.earnedDate,
      );
    }).toList();
  }
}

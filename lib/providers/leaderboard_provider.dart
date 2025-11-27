import 'package:flutter/material.dart';
import '../models/leaderboard_user.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> entries = [];

  /// Add or update a user entry
  void addOrUpdateEntry(LeaderboardEntry entry) {
    final index = entries.indexWhere((e) => e.userId == entry.userId);
    if (index >= 0) {
      entries[index] = entry; // update
    } else {
      entries.add(entry);
    }
    // Sort descending by score
    entries.sort((a, b) => b.score.compareTo(a.score));
    notifyListeners();
  }

  /// Get top N users
  List<LeaderboardEntry> top(int n) => entries.take(n).toList();
}

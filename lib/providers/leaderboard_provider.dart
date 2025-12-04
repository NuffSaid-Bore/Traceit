import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trace_it/core/services/firestore_service.dart';
import 'package:trace_it/models/leaderboard_mode.dart';
import '../models/leaderboard_user.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> entries = [];
  StreamSubscription? _subscription;

  LeaderboardMode mode = LeaderboardMode.global;

  LeaderboardProvider() {
    setMode(LeaderboardMode.global);
  
  }

  void _listenToLeaderboard() {
    _subscription = FirestoreService.leaderboardStream().listen((list) {
      entries = list.map((e) => LeaderboardEntry.fromFirestore(e)).toList();

      for (int i = 0; i < entries.length; i++) {
        entries[i].previousRank = i;
      }

      // Sort by score
      entries.sort((a, b) => b.score.compareTo(a.score));

      notifyListeners();
    });
  }

  void updateRanks() {
    for (int i = 0; i < entries.length; i++) {
      entries[i].previousRank; // First load
      entries[i].previousRank = entries[i].previousRank;
    }
  }

  void setMode(LeaderboardMode newMode) {
    mode = newMode;
    _subscription?.cancel();

    _subscription = FirestoreService.leaderboardStream(mode: mode).listen((
      list,
    ) {
      entries.clear();
      entries = list.map((e) => LeaderboardEntry.fromFirestore(e)).toList();
      notifyListeners();
    });
  }

  Future<void> refreshLeaderboard() async {
    _subscription?.cancel();

    final list = await FirestoreService.getLeaderboard(limit: 50);

    entries = list.map((e) => LeaderboardEntry.fromFirestore(e)).toList();

    entries.sort((a, b) => b.score.compareTo(a.score));

    for (int i = 0; i < entries.length; i++) {
      entries[i].previousRank = i;
    }

    notifyListeners();

    _listenToLeaderboard();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

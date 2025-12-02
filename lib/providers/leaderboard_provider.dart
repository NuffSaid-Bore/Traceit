import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trace_it/core/services/firestore_service.dart';
import '../models/leaderboard_user.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> entries = [];
  StreamSubscription? _subscription;

  LeaderboardProvider() {
    _listenToLeaderboard();
  }

  void _listenToLeaderboard() {
    _subscription = FirestoreService.leaderboardStream().listen((rawList) {
      entries = rawList
          .map((data) => LeaderboardEntry.fromFirestore(data))
          .toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

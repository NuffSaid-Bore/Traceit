import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trace_it/app.dart';
import 'models/leaderboard_user.dart';
import 'data/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register your Hive adapters for Puzzle, UserState, etc.
  registerHiveAdapters();

  // Register Hive adapter for LeaderboardEntry (already have it)
  Hive.registerAdapter(LeaderboardEntryAdapter());

  // Open Hive boxes
  await Hive.openBox<LeaderboardEntry>('leaderboard');
  await Hive.openBox('puzzleBox'); // box for saved puzzles / user state

  // Start the app
  runApp(const ZipApp());
}



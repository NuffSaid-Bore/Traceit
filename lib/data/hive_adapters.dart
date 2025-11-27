// lib/data/hive_adapters.dart
import 'package:hive/hive.dart';
import '../models/puzzle.dart';
import '../models/user_state.dart';

/// Call this at app startup to register all Hive adapters
void registerHiveAdapters() {
  // Make sure PuzzleAdapter and UserStateAdapter are generated via build_runner
  Hive.registerAdapter(PuzzleAdapter());
  Hive.registerAdapter(UserStateAdapter());
}

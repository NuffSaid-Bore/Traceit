import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:trace_it/core/services/firestore_service.dart';
import 'package:trace_it/models/leaderboard_user.dart';
import 'package:trace_it/models/user_state.dart';

class StorageService {
  static const String puzzleBox = "puzzleBox";
  static const String lastPuzzleKey = "lastPuzzle";
  static const String leaderboardKey = "leaderboard";

  static Future<void> savePuzzle(UserState userState) async {
    final box = await Hive.openBox(puzzleBox);
    await box.put(lastPuzzleKey, userState);
  }

  static Future<UserState?> loadPuzzle() async {
    final box = await Hive.openBox(puzzleBox);
    return box.get(lastPuzzleKey) as UserState?;
  }

  static Future<void> clearPuzzle() async {
    final box = await Hive.openBox(puzzleBox);
    await box.delete(lastPuzzleKey);
  }

  // --- Leaderboard methods ---
  static Future<void> saveLeaderboard(List<LeaderboardEntry> entries) async {
    final box = await Hive.openBox<LeaderboardEntry>(puzzleBox);

    // Store each entry individually
    for (var entry in entries) {
      await box.put(entry.userId, entry);
    }
  }

  static Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final box = await Hive.openBox<LeaderboardEntry>(puzzleBox);
    return box.values.toList();
  }

  static Future<void> completePuzzle(int attempts, int elapsedSeconds) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirestoreService.saveGameResult(userId, attempts, elapsedSeconds);
  }

}

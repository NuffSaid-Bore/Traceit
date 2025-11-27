import 'package:hive/hive.dart';
import 'package:trace_it/models/user_state.dart';

class StorageService {
  static const String puzzleBox = "puzzleBox";
  static const String lastPuzzleKey = "lastPuzzle";

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
}

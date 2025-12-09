import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../models/user_state.dart';
import '../core/services/storage_service.dart';
import '../core/services/firestore_service.dart';

class GameStateProvider extends ChangeNotifier {
  UserState? _currentState;

  UserState? get currentState => _currentState;

  bool get hasSavedGame => _currentState != null;

  /// Start a new game
  void starstNewGame(Puzzle puzzle, {int difficulty = 1}) async {
    _currentState = UserState(puzzle: puzzle, difficulty: difficulty);
    await _saveState(); // local save
    await FirestoreService.saveUserState(_currentState!); // cloud save
    notifyListeners();
  }

  /// Restore game from loaded state
  void restoreGame(UserState state) {
    _currentState = state;
    notifyListeners();
  }

  /// Increment attempts
  void incrementAttempts() async {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(
        attempts: _currentState!.attempts + 1
    );
    await _saveState();
    await FirestoreService.saveUserState(_currentState!);
    notifyListeners();
  }

  /// Update timer
  void updateTimer(int elapsedSeconds) async {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(elapsedSeconds: elapsedSeconds);
    await _saveState();
    await FirestoreService.saveUserState(_currentState!);
    notifyListeners();
  }

  /// Complete game and clear local state
  void completeGame() async {
    _currentState = null;
    await StorageService.clearPuzzle();
    await FirestoreService.clearUserState(); // optional: remove temp game state in Firestore
    notifyListeners();
  }

  /// Local storage save
  Future<void> _saveState() async {
    if (_currentState != null) {
      await StorageService.savePuzzle(_currentState!);
    }
  }

  /// Load saved game from Firestore first, fallback to local storage
 Future<void> loadSavedGame() async {
  try {
    print("Loading saved game...");

    UserState? saved = await FirestoreService.loadUserState();
    saved ??= await StorageService.loadPuzzle();

    if (saved != null) {
      _currentState = saved;
      print("Saved game loaded.");
      notifyListeners();
    } else {
      print("No saved game found.");
    }

  } catch (e, st) {
    print("ERROR while loading saved game: $e");
    print(st);
  }
}


  Future<void> saveGame() async {
  if (_currentState != null) {
    // Save to Firestore
    await FirestoreService.saveUserState(_currentState!);
  }
  notifyListeners();
}

Future<void> clearAllState() async {
  _currentState = null;
  notifyListeners();

  // Clear local storage
  await StorageService.clearPuzzle();
}


}

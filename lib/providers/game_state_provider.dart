import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../models/user_state.dart';
import '../core/services/storage_service.dart';


class GameStateProvider extends ChangeNotifier {
  UserState? _currentState;

  UserState? get currentState => _currentState;

  bool get hasSavedGame => _currentState != null;

  void startNewGame(Puzzle puzzle, {int difficulty = 1}) {
    _currentState = UserState(puzzle: puzzle, difficulty: difficulty);
    _saveState();
    notifyListeners();
  }

  void restoreGame(UserState state) {
    _currentState = state;
    notifyListeners();
  }

  void incrementAttempts() {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(attempts: _currentState!.attempts + 1);
    _saveState();
    notifyListeners();
  }

  void updateTimer(int elapsedSeconds) {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(elapsedSeconds: elapsedSeconds);
    _saveState();
    notifyListeners();
  }

  void completeGame() {
    _currentState = null;
    StorageService.clearPuzzle();
    notifyListeners();
  }

  Future<void> _saveState() async {
    if (_currentState != null) {
      await StorageService.savePuzzle(_currentState!);
    }
  }

  Future<void> loadSavedGame() async {
    UserState? saved = await StorageService.loadPuzzle();
    if (saved != null) {
      _currentState = saved;
      notifyListeners();
    }
  }
}

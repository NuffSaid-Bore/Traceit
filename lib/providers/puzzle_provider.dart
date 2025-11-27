import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trace_it/models/leaderboard_user.dart';
import 'package:trace_it/providers/leaderboard_provider.dart';
import '../models/puzzle.dart';
import '../core/utils/puzzle_generator.dart';

class PuzzleProvider extends ChangeNotifier {

  final LeaderboardProvider leaderboardProvider;

  PuzzleProvider({required this.leaderboardProvider});
  Puzzle? currentPuzzle;

  int attempts = 0;
  Duration elapsed = Duration.zero;
  Timer? _timer;
  bool isRunning = false;

  Color lineColor = Colors.blue;

  List<Offset> drawnPath = [];
  List<Offset> visitedCells = [];

  int currentStreak = 0;
  int maxStreak = 0;

  /// Call when a puzzle is won
  void recordWin() {
    currentStreak++;
    if (currentStreak > maxStreak) maxStreak = currentStreak;
    notifyListeners();
  }

  /// Call when a puzzle is lost or undo
  void recordLoss() {
    currentStreak = 0;
    notifyListeners();
  }

  /// Generate a new puzzle
  void generateNewPuzzle(int difficulty) {
    currentPuzzle = PuzzleGenerator.generate(difficulty);
    resetGame();
    notifyListeners();
  }

  /// Start the timer
  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// Stop the timer
  void stopTimer() {
    _timer?.cancel();
    isRunning = false;
  }

  /// Reset the drawn path & visited cells
  void resetGame() {
    stopTimer();
    elapsed = Duration.zero;
    drawnPath.clear();
    visitedCells.clear();
    attempts++;
    notifyListeners();
  }

  /// Add cell to current path
  void addCell(Offset cell, Offset pixelOffset) {
    // Prevent revisit
    if (visitedCells.contains(cell)) return;

    visitedCells.add(cell);
    drawnPath.add(pixelOffset);

    // Start timer on first cell
    if (!isRunning) startTimer();

    notifyListeners();
  }

  /// Check win condition
  bool checkWin() {
    final puzzle = currentPuzzle;
    if (puzzle == null) return false;

    // Must visit all cells
    if (visitedCells.length != puzzle.rows * puzzle.cols) return false;

    // Check numbers are in order along visitedCells
    final numberPositions = puzzle.numbers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (int i = 0; i < numberPositions.length; i++) {
      if (!visitedCells.contains(numberPositions[i].value)) return false;
    }

    return true;
  }

  void reportScore(String userId, String username) {
  if (currentPuzzle == null) return;
  final seconds = elapsed.inSeconds.toDouble();

  final entryIndex = leaderboardProvider.entries.indexWhere((e) => e.userId == userId);
  if (entryIndex >= 0) {
    // Update average time
    final oldEntry = leaderboardProvider.entries[entryIndex];
    final newAvgTime = ((oldEntry.averageTime * oldEntry.puzzlesCompleted) + seconds) /
        (oldEntry.puzzlesCompleted + 1);
    leaderboardProvider.addOrUpdateEntry(
      LeaderboardEntry(
        userId: userId,
        username: username,
        puzzlesCompleted: oldEntry.puzzlesCompleted + 1,
        averageTime: newAvgTime,
      ),
    );
  } else {
    leaderboardProvider.addOrUpdateEntry(
      LeaderboardEntry(
        userId: userId,
        username: username,
        puzzlesCompleted: 1,
        averageTime: seconds,
      ),
    );
  }
}


  /// Undo functionality (reset board)
  void undo() {
    resetGame();
  }

  /// Cycle line color per stage
  void nextStageColor() {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    int index = colors.indexOf(lineColor);
    lineColor = colors[(index + 1) % colors.length];
    notifyListeners();
  }
}

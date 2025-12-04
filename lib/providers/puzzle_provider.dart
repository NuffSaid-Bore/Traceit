import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trace_it/providers/leaderboard_provider.dart';
import '../models/puzzle.dart';
import '../core/utils/puzzle_generator.dart';

class PuzzleProvider extends ChangeNotifier {
  LeaderboardProvider? leaderboardProvider;
  int currentWinStreak = 0;

  PuzzleProvider({required this.leaderboardProvider});
  Puzzle? currentPuzzle;

  int attempts = 1;
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
    currentWinStreak++;
    if (currentStreak > maxStreak) maxStreak = currentStreak;
    notifyListeners();
  }

  /// Call when a puzzle is lost or undo
  void recordLoss() {
    currentStreak = 0;
    notifyListeners();
  }

  /// Generate a new puzzle
  Future<void> generateNewPuzzle(
    int size,
    PuzzlePathMode mode,
    int totalNumbers,
  ) async {
    currentPuzzle = await PuzzleGenerator.generatePuzzleAsync(
      size: size,
      mode: mode,
      totalNumbers: totalNumbers,
    );
    startNewGame();
    notifyListeners();
  }

  void startNewGame() {
    stopTimer();
    elapsed = Duration.zero;
    drawnPath.clear();
    visitedCells.clear();
    attempts = 1;
    currentWinStreak = 0;
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
    currentWinStreak = 0;
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

    // 1. Must visit all cells exactly once
    if (visitedCells.length != puzzle.rows * puzzle.cols) return false;

    final uniqueVisited = visitedCells.toSet();
    if (uniqueVisited.length != visitedCells.length)
      return false; // no duplicates

    // 2. Get number → cell mapping sorted by number
    final sortedNumbers = puzzle.numbers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // 3. Check that numerical cells appear in the visited path IN ORDER
    int lastIndex = -1;
    for (var entry in sortedNumbers) {
      final numberCell = entry.value;

      int indexInPath = visitedCells.indexOf(numberCell);
      if (indexInPath == -1) return false; // number not visited

      if (indexInPath < lastIndex) return false; // out of order

      lastIndex = indexInPath;
    }

    // 4. OPTIONAL: enforce adjacency (no jumping)
    for (int i = 1; i < visitedCells.length; i++) {
      final prev = visitedCells[i - 1];
      final curr = visitedCells[i];

      if ((prev.dx - curr.dx).abs() + (prev.dy - curr.dy).abs() != 1) {
        return false; // not adjacent
      }
    }

    return true;
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
      Colors.purple,
      Colors.deepPurple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
      Colors.lime,
    ];
    int index = colors.indexOf(lineColor);
    lineColor = colors[(index + 1) % colors.length];
    notifyListeners();
  }
}

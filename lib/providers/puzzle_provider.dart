import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/models/win_results.dart';
import 'package:trace_it/providers/game_state_provider.dart';
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

  int failCount = 0;
  int puzzlesCompleted = 0;
  num totalTime = 0;
  double averageTime = 0;
  int currentDifficulty = 1;

  bool userStatsLoaded = false;

  int computeDynamicDifficulty() {
    int base = currentDifficulty;

    // Your local difficulty logic
    if (currentStreak >= 3) base += 1;
    if (failCount >= 2) base -= 1;

    // Firestore-based difficulty
    if (averageTime < 20) base += 1;

    return base.clamp(1, 10);
  }

  Future<void> loadUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    puzzlesCompleted = (data['puzzlesCompleted'] ?? 0) as int;
    totalTime = (data['totalTime'] ?? 0) as num;

    averageTime = puzzlesCompleted > 0 ? totalTime / puzzlesCompleted : 0.0;

    userStatsLoaded = true;

    notifyListeners();
  }

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
    BuildContext context,
  ) async {
    currentPuzzle = await PuzzleGenerator.generatePuzzleAsync(
      size: size,
      mode: mode,
      totalNumbers: totalNumbers,
    );

    final gameState = context.read<GameStateProvider>();
    gameState.starstNewGame(currentPuzzle!, difficulty: currentDifficulty);
    startNewGame();
    notifyListeners();
  }

  /// Generate a new difficult puzzle
  /// // need to be refined
  Future<void> generateNewDifficultPuzzle(
    int size,
    PuzzlePathMode mode,
    int totalNumbers,
    BuildContext context,
  ) async {
    if (!userStatsLoaded) {
      await loadUserStats();
    }
    final difficulty = computeDynamicDifficulty();
    currentPuzzle = await PuzzleGenerator.generateNewDifficultPuzzleAsync(
      size: size,
      mode: mode,
      totalNumbers: totalNumbers,
      difficulty: difficulty,
    );
    final gameState = context.read<GameStateProvider>();
    gameState.starstNewGame(currentPuzzle!, difficulty: currentDifficulty);
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
    failCount++;
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
  WinResult checkWin() {
    final puzzle = currentPuzzle;
    if (puzzle == null) return WinResult.notAllCellsVisited;

    // 1. Must visit all cells exactly once
    if (visitedCells.length != puzzle.rows * puzzle.cols) {
      return WinResult.notAllCellsVisited;
    }

    final uniqueVisited = visitedCells.toSet();
    if (uniqueVisited.length != visitedCells.length) {
      return WinResult.duplicateCell;
    } // no duplicates

    // 2. Get number → cell mapping sorted by number
    final sortedNumbers = puzzle.numbers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // 3. Check that numerical cells appear in the visited path IN ORDER
    int lastIndex = -1;
    for (var entry in sortedNumbers) {
      final numberCell = entry.value;

      int indexInPath = visitedCells.indexOf(numberCell);
      if (indexInPath == -1)
        {return WinResult.numberMissing; }// number not visited

      if (indexInPath < lastIndex)
        {return WinResult.numberOrderIncorrect;} // out of order

      lastIndex = indexInPath;
    }

    // 4. OPTIONAL: enforce adjacency (no jumping)
    for (int i = 1; i < visitedCells.length; i++) {
      final prev = visitedCells[i - 1];
      final curr = visitedCells[i];

      if ((prev.dx - curr.dx).abs() + (prev.dy - curr.dy).abs() != 1) {
        WinResult.nonAdjacentMove; // not adjacent
      }
    }

    return WinResult.success;
  }

  /// Undo functionality (reset board)
  void undo() {
    resetGame();
  }

  /// Cycle line color per stage
  void nextStageColor() {
    List<Color> colors = [
      Colors.yellow,
      Colors.pinkAccent,
      Colors.white,
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

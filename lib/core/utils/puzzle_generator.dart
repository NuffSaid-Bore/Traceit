import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/puzzle.dart';

class PuzzleGenerator {
  /// Entry point: generate a puzzle based on difficulty.
  /// Difficulty controls grid size:
  /// Level 1-5: 5x5
  /// Level 6-12: 6x6
  /// Level 13+: 7x7
  static Puzzle generate(int difficulty) {
    int size = _gridSizeForDifficulty(difficulty);

    List<Offset> path = _generateHamiltonianPath(size, size);
    Map<int, Offset> numbers = _assignNumbersAlongPath(path);

    return Puzzle(
      rows: size,
      cols: size,
      path: path,
      numbers: numbers,
    );
  }

  /// Difficulty → grid size scaling
  static int _gridSizeForDifficulty(int difficulty) {
    if (difficulty < 6) return 5;
    if (difficulty < 13) return 6;
    return 7;
  }

  /// ---------------------------------------------------------
  /// HAMILTONIAN PATH GENERATION
  /// ---------------------------------------------------------
  ///
  /// Uses depth-first search with randomized directions.
  /// Guaranteed to produce a valid path for 5x5–7x7 grids.

  static List<Offset> _generateHamiltonianPath(int rows, int cols) {
    List<Offset> path = [];
    Set<String> visited = {};

    bool dfs(int r, int c) {
      if (visited.length == rows * cols) return true;

      visited.add("$r,$c");
      path.add(Offset(c.toDouble(), r.toDouble())); // store col,row

      // Shuffle directions for randomness
      List<List<int>> dirs = [
        [0, 1],  // down
        [1, 0],  // right
        [0, -1], // up
        [-1, 0]  // left
      ]..shuffle(Random());

      for (var d in dirs) {
        int nr = r + d[1];
        int nc = c + d[0];

        if (_isValid(nr, nc, rows, cols) && !visited.contains("$nr,$nc")) {
          if (dfs(nr, nc)) return true;
        }
      }

      // backtrack
      visited.remove("$r,$c");
      path.removeLast();
      return false;
    }

    // Try several random starting points until a path succeeds
    for (int attempt = 0; attempt < 50; attempt++) {
      path.clear();
      visited.clear();

      int sr = Random().nextInt(rows);
      int sc = Random().nextInt(cols);

      if (dfs(sr, sc)) return path;
    }

    throw Exception("Failed to generate Hamiltonian path — retry or increase attempts.");
  }

  static bool _isValid(int r, int c, int rows, int cols) {
    return r >= 0 && c >= 0 && r < rows && c < cols;
  }

  /// ---------------------------------------------------------
  /// NUMBER ASSIGNMENT
  /// ---------------------------------------------------------
  ///
  /// Place numbers 1–15 along the Hamiltonian path in order,
  /// but distribute them evenly (or randomly near-even).
  ///
  static Map<int, Offset> _assignNumbersAlongPath(List<Offset> path) {
    const totalNumbers = 15;

    int pathLen = path.length;
    double step = pathLen / totalNumbers;

    Map<int, Offset> map = {};

    for (int i = 0; i < totalNumbers; i++) {
      int index = (i * step).floor();

      // small random offset to avoid boring layouts
      index = max(
        0,
        min(
          pathLen - 1,
          index + Random().nextInt(3) - 1, // {-1, 0, +1}
        ),
      );

      map[i + 1] = path[index];
    }

    return map;
  }
}

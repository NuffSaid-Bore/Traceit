import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/models/win_results.dart';
import 'package:trace_it/ui/painters/grid_painter.dart';
import '../../models/puzzle.dart';
import '../../providers/puzzle_provider.dart';
import 'puzzle_number_circle.dart';
import 'dart:math';

class GridBoard extends StatefulWidget {
  const GridBoard({super.key});

  @override
  State<GridBoard> createState() => _GridBoardState();
}

class _GridBoardState extends State<GridBoard> {
  late double cellWidth;
  late double cellHeight;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context);
    final puzzle = provider.currentPuzzle;

    if (puzzle == null) return const Center(child: Text("No puzzle loaded"));

    return LayoutBuilder(
      builder: (context, constraints) {
        cellWidth = constraints.maxWidth / puzzle.cols;
        cellHeight = constraints.maxHeight / puzzle.rows;

        return GestureDetector(
          onPanStart: (details) =>
              _handleDraw(details.localPosition, puzzle, provider),
          onPanUpdate: (details) =>
              _handleDraw(details.localPosition, puzzle, provider),
          onPanEnd: (_) async {
            final provider = Provider.of<PuzzleProvider>(
              context,
              listen: false,
            );

            final result = provider.checkWin();

            if (result == WinResult.success) {
              provider.stopTimer();
              provider.nextStageColor();
              provider.failCount = 0;
              Navigator.pushNamed(context, "/celebrate");
            } else {
              String message;

              switch (result) {
                case WinResult.notAllCellsVisited:
                  message = "Oops! You missed some grid cells!";
                  break;
                case WinResult.duplicateCell:
                  message = "Oops! You revisited a cell!";
                  break;
                case WinResult.numberMissing:
                  message = "Oops! You Missed a Number...";
                  break;
                case WinResult.numberOrderIncorrect:
                  message = "Oops! Numbers weren't in order!";
                  break;
                case WinResult.nonAdjacentMove:
                  message = "Invalid move: You jumped or moved diagonally!";
                  break;
                default:
                  message = "Oops! Could not complete the puzzle.";
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent.shade100,
                  content: Text(
                    message,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  action: SnackBarAction(
                    label: 'Reset',
                    onPressed: () {
                      provider.undo();
                      provider.startTimer();
                    },
                    textColor: Colors.redAccent.shade100,
                    backgroundColor: Colors.redAccent,
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },

          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: GridLinePainter(
              rows: puzzle.rows,
              cols: puzzle.cols,
              drawnPath: provider.drawnPath,
              lineColor: provider.lineColor,
              barriers: puzzle.barriers,
            ),
            child: Stack(
              children: [
                for (var entry in puzzle.numbers.entries)
                  PuzzleNumberCircle(
                    number: entry.key,
                    position: _cellCenter(entry.value),
                    size: min(cellWidth, cellHeight) * 0.8,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _cellCenter(Offset cell) {
    return Offset((cell.dx + 0.5) * cellWidth, (cell.dy + 0.5) * cellHeight);
  }

  void _handleDraw(
    Offset localPosition,
    Puzzle puzzle,
    PuzzleProvider provider,
  ) {
    int col = (localPosition.dx / cellWidth).floor();
    int row = (localPosition.dy / cellHeight).floor();

    col = col.clamp(0, puzzle.cols - 1);
    row = row.clamp(0, puzzle.rows - 1);

    Offset cell = Offset(col.toDouble(), row.toDouble());

    // Prevent diagonal or jumping
    if (provider.visitedCells.isNotEmpty) {
      Offset last = provider.visitedCells.last;
      if ((last.dx - cell.dx).abs() + (last.dy - cell.dy).abs() > 1) return;
      // Prevent blocked movement
      if (_isMoveBlocked(last, cell, puzzle)) return;
    }

    provider.addCell(cell, _cellCenter(cell));
  }

  bool _isMoveBlocked(Offset from, Offset to, Puzzle puzzle) {
    final dx = (to.dx - from.dx);
    final dy = (to.dy - from.dy);

    final barriers = puzzle.barriers[from] ?? [];

    if (dx == 1 && dy == 0 && barriers.contains("right")) return true;
    if (dx == -1 && dy == 0 && barriers.contains("left")) return true;
    if (dx == 0 && dy == 1 && barriers.contains("down")) return true;
    if (dx == 0 && dy == -1 && barriers.contains("up")) return true;

    return false;
  }
}

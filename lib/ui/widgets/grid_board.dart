import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

            if (provider.checkWin()) {
              provider.stopTimer();
              provider.nextStageColor();
              // Trigger celebration screen
              Navigator.pushNamed(context, "/celebrate").then((_) {
              });
            } else {
              // Show a SnackBar to notify the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent.shade100,
                  content: const Text(
                    "Oops! 😂 Failed to Solve the Puzzle. Try again.",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
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
    }

    provider.addCell(cell, _cellCenter(cell));
  }
}

import 'package:flutter/material.dart';

class GridLinePainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Offset> drawnPath; // points in pixel coordinates
  final Color lineColor;
  final Map<Offset, List<String>> barriers;

  GridLinePainter({
    required this.rows,
    required this.cols,
    required this.drawnPath,
    required this.lineColor,
    this.barriers = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // --- 1. Draw the grid lines ---
    final gridPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (int c = 0; c <= cols; c++) {
      final x = c * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (int r = 0; r <= rows; r++) {
      final y = r * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // --- 2. Draw the drawn path ---
    if (drawnPath.isNotEmpty) {
      final pathPaint = Paint()
        ..color = lineColor
        ..strokeWidth = 15
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(drawnPath.first.dx, drawnPath.first.dy);
      for (int i = 1; i < drawnPath.length; i++) {
        path.lineTo(drawnPath[i].dx, drawnPath[i].dy);
      }

      canvas.drawPath(path, pathPaint);
    }
    _drawBarriers(canvas, cellWidth, cellHeight);
  }

    void _drawBarriers(Canvas canvas, double cellW, double cellH) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    barriers.forEach((cell, dirs) {
      final x = cell.dx * cellW;
      final y = cell.dy * cellH;

      for (var dir in dirs) {
        switch (dir) {
          case "up":
            canvas.drawLine(
              Offset(x, y),
              Offset(x + cellW, y),
              paint,
            );
            break;
          case "down":
            canvas.drawLine(
              Offset(x, y + cellH),
              Offset(x + cellW, y + cellH),
              paint,
            );
            break;
          case "left":
            canvas.drawLine(
              Offset(x, y),
              Offset(x, y + cellH),
              paint,
            );
            break;
          case "right":
            canvas.drawLine(
              Offset(x + cellW, y),
              Offset(x + cellW, y + cellH),
              paint,
            );
            break;
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant GridLinePainter oldDelegate) {
    return oldDelegate.drawnPath != drawnPath ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.lineColor != lineColor;
  }
}

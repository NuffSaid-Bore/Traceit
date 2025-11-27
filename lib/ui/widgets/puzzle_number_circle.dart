import 'package:flutter/material.dart';

class PuzzleNumberCircle extends StatelessWidget {
  final int number;
  final Offset position;
  final double size;

  const PuzzleNumberCircle({
    super.key,
    required this.number,
    required this.position,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          "$number",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

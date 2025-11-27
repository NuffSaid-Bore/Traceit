import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'puzzle.g.dart'; // <- necessary for code generation

@HiveType(typeId: 0)
class Puzzle {
  @HiveField(0)
  final int rows;

  @HiveField(1)
  final int cols;

  @HiveField(2)
  final List<Offset> path;

  @HiveField(3)
  final Map<int, Offset> numbers;

  Puzzle({
    required this.rows,
    required this.cols,
    required this.path,
    required this.numbers,
  });
}



// class PuzzleCell {
//   final Offset position;
//   final int? number;

//   PuzzleCell({
//     required this.position,
//     this.number,
//   });
// }
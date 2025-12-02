import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'puzzle.g.dart'; // <- necessary for code generation

@HiveType(typeId: 2)
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

  /// Convert Puzzle to Map for Firestore / JSON
  Map<String, dynamic> toMap() {
    return {
      'rows': rows,
      'cols': cols,
      'path': path.map((o) => {'dx': o.dx, 'dy': o.dy}).toList(),
      'numbers': numbers.map(
        (key, value) =>
            MapEntry(key.toString(), {'dx': value.dx, 'dy': value.dy}),
      ),
    };
  }

  /// Create Puzzle from Map
  factory Puzzle.fromMap(Map<String, dynamic> map) {
    return Puzzle(
      rows: map['rows'] ?? 0,
      cols: map['cols'] ?? 0,
      path:
          (map['path'] as List<dynamic>?)
              ?.map(
                (e) => Offset(
                  (e['dx'] as num).toDouble(),
                  (e['dy'] as num).toDouble(),
                ),
              )
              .toList() ??
          [],
      numbers:
          (map['numbers'] as Map<String, dynamic>?)?.map((key, value) {
            final v = value as Map<String, dynamic>;
            return MapEntry(
              int.parse(key),
              Offset((v['dx'] as num).toDouble(), (v['dy'] as num).toDouble()),
            );
          }) ??
          {},
    );
  }
}

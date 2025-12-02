// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PuzzleAdapter extends TypeAdapter<Puzzle> {
  @override
  final int typeId = 2;

  @override
  Puzzle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Puzzle(
      rows: fields[0] as int,
      cols: fields[1] as int,
      path: (fields[2] as List).cast<Offset>(),
      numbers: (fields[3] as Map).cast<int, Offset>(),
    );
  }

  @override
  void write(BinaryWriter writer, Puzzle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.rows)
      ..writeByte(1)
      ..write(obj.cols)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.numbers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

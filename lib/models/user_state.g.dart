// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStateAdapter extends TypeAdapter<UserState> {
  @override
  final int typeId = 3;

  @override
  UserState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserState(
      puzzle: fields[0] as Puzzle,
      attempts: fields[1] as int,
      elapsedSeconds: fields[2] as int,
      difficulty: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.puzzle)
      ..writeByte(1)
      ..write(obj.attempts)
      ..writeByte(2)
      ..write(obj.elapsedSeconds)
      ..writeByte(3)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

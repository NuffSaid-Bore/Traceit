// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = 1;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardEntry(
      userId: fields[0] as String,
      username: fields[1] as String,
      puzzlesCompleted: fields[2] as int,
      averageTime: fields[3] as double,
      totalTime: fields[4] as double,
      weeklyCompleted: fields[5] as int,
      weeklyTime: fields[6] as double,
      monthlyCompleted: fields[7] as int,
      monthlyTime: fields[8] as double,
      previousRank: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.puzzlesCompleted)
      ..writeByte(3)
      ..write(obj.averageTime)
      ..writeByte(4)
      ..write(obj.totalTime)
      ..writeByte(5)
      ..write(obj.weeklyCompleted)
      ..writeByte(6)
      ..write(obj.weeklyTime)
      ..writeByte(7)
      ..write(obj.monthlyCompleted)
      ..writeByte(8)
      ..write(obj.monthlyTime)
      ..writeByte(9)
      ..write(obj.previousRank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

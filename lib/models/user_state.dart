import 'package:hive/hive.dart';
import 'puzzle.dart';

part 'user_state.g.dart';

@HiveType(typeId: 1)
class UserState {
  @HiveField(0)
  final Puzzle puzzle;

  @HiveField(1)
  final int attempts;

  @HiveField(2)
  final int elapsedSeconds;

  @HiveField(3)
  final int difficulty;

  UserState({
    required this.puzzle,
    this.attempts = 0,
    this.elapsedSeconds = 0,
    this.difficulty = 1,
  });

  /// Creates a new UserState with updated fields
  UserState copyWith({
    Puzzle? puzzle,
    int? attempts,
    int? elapsedSeconds,
    int? difficulty,
  }) {
    return UserState(
      puzzle: puzzle ?? this.puzzle,
      attempts: attempts ?? this.attempts,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

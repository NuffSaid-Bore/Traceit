import 'package:hive/hive.dart';
import 'puzzle.dart';

part 'user_state.g.dart';

@HiveType(typeId: 3)
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

  /// Convert UserState to Map for Firestore or JSON
Map<String, dynamic> toMap() {
  return {
    'savedGame': {
      'puzzle': puzzle.toMap(),
      'attempts': attempts,
      'elapsedSeconds': elapsedSeconds,
      'difficulty': difficulty,
    }
  };
}



  /// Create UserState from Map
  factory UserState.fromMap(Map<String, dynamic> map) {
  if (!map.containsKey('savedGame')) {
    throw Exception("No saved game data found");
  }

  final sg = Map<String, dynamic>.from(map['savedGame']);

  return UserState(
    puzzle: Puzzle.fromMap(Map<String, dynamic>.from(sg['puzzle'])),
    attempts: sg['attempts'] ?? 0,
    elapsedSeconds: sg['elapsedSeconds'] ?? 0,
    difficulty: sg['difficulty'] ?? 1,
  );
}


}

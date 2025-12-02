import 'package:hive/hive.dart';

part 'leaderboard_user.g.dart';

@HiveType(typeId: 1) // unique typeId per class
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String username;

  @HiveField(2)
  int puzzlesCompleted;

  @HiveField(3)
  double averageTime; // in seconds

  @HiveField(4)
  double totalTime; // in seconds

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.puzzlesCompleted,
    required this.averageTime,
    required this.totalTime,
  });

  // Use totalTime to calculate the score correctly
  double get score => puzzlesCompleted / (totalTime + 1);

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'username': username,
        'puzzlesCompleted': puzzlesCompleted,
        'averageTime': averageTime,
        'totalTime': totalTime,
      };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) => LeaderboardEntry(
        userId: map['userId'],
        username: map['username'],
        puzzlesCompleted: map['puzzlesCompleted'],
        averageTime: (map['averageTime'] as num).toDouble(),
        totalTime: (map['totalTime'] as num).toDouble(),
      );

 factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data) {
  return LeaderboardEntry(
    userId: data['userId'] ?? '',
    username: data['username'] ?? 'Player',
    puzzlesCompleted: (data['puzzlesCompleted'] ?? 0) as int,
    averageTime: (data['averageTime'] ?? 0).toDouble(),
    totalTime: (data['totalTime'] ?? 0).toDouble(),
  );
}

}

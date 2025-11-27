import 'package:hive/hive.dart';

part 'leaderboard_user.g.dart'; 

@HiveType(typeId: 0) // unique typeId per class
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String username;

  @HiveField(2)
  int puzzlesCompleted;

  @HiveField(3)
  double averageTime; // in seconds

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.puzzlesCompleted,
    required this.averageTime,
  });

  double get score => puzzlesCompleted / (averageTime + 1);

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'username': username,
        'puzzlesCompleted': puzzlesCompleted,
        'averageTime': averageTime,
      };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) => LeaderboardEntry(
        userId: map['userId'],
        username: map['username'],
        puzzlesCompleted: map['puzzlesCompleted'],
        averageTime: map['averageTime'].toDouble(),
      );
}

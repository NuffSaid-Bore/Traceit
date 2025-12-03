import 'package:hive/hive.dart';
part 'leaderboard_user.g.dart';

@HiveType(typeId: 1)
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String username;

  @HiveField(2)
  int puzzlesCompleted;

  @HiveField(3)
  double averageTime;

  @HiveField(4)
  double totalTime;

  @HiveField(5)
  int weeklyCompleted;

  @HiveField(6)
  double weeklyTime;

  @HiveField(7)
  int monthlyCompleted;

  @HiveField(8)
  double monthlyTime;

  @HiveField(9)
  int previousRank;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.puzzlesCompleted,
    required this.averageTime,
    required this.totalTime,
    this.weeklyCompleted = 0,
    this.weeklyTime = 0,
    this.monthlyCompleted = 0,
    this.monthlyTime = 0,
    this.previousRank = -1,
  });

  double get score => puzzlesCompleted * 1000 / (averageTime + 1);

  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data) {
    return LeaderboardEntry(
      userId: data['userId'],
      username: data['username'] ?? 'Player',
      puzzlesCompleted: data['puzzlesCompleted'] ?? 0,
      totalTime: (data['totalTime'] ?? 0).toDouble(),
      averageTime:
          data['averageTime']?.toDouble() ??
          ((data['totalTime'] ?? 0) / (data['puzzlesCompleted'] ?? 1)),
      weeklyCompleted: data['weeklyCompleted'] ?? 0,
      weeklyTime: (data['weeklyTime'] ?? 0).toDouble(),
      monthlyCompleted: data['monthlyCompleted'] ?? 0,
      monthlyTime: (data['monthlyTime'] ?? 0).toDouble(),
    );
  }
}

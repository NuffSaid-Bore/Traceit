import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trace_it/models/user_state.dart';

class FirestoreService {
  static final _users = FirebaseFirestore.instance.collection('users');

  // ===== User GameState =====
  static Future<void> saveUserState(UserState state) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _users.doc(uid).set(state.toMap(), SetOptions(merge: true));
  }

  static Future<UserState?> loadUserState() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserState.fromMap(doc.data()!);
  }

  static Future<void> clearUserState() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _users.doc(uid).update({'currentPuzzle': null});
  }

  // ===== Leaderboard =====
  static Future<void> saveGameResult(
    String userId,
    int attempts,
    int elapsedSeconds,
  ) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      int puzzlesCompleted = data['puzzlesCompleted'] ?? 0;
      int totalTime = data['totalTime'] ?? 0;

      transaction.update(docRef, {
        'puzzlesCompleted': puzzlesCompleted + attempts,
        'totalTime': totalTime + elapsedSeconds,
      });
    });
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard({
    int limit = 10,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('puzzlesCompleted', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final puzzlesCompleted = data['puzzlesCompleted'] ?? 0;
      final totalTime = data['totalTime'] ?? 0;

      return {
        'userId': doc.id,
        'username': data['username'],
        'score': puzzlesCompleted / (totalTime + 1),
        'puzzlesCompleted': puzzlesCompleted,
        'averageTime': puzzlesCompleted > 0 ? totalTime / puzzlesCompleted : 0,
      };
    }).toList();
  }

  static Stream<List<Map<String, dynamic>>> leaderboardStream({
    int limit = 10,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('puzzlesCompleted', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final puzzlesCompleted = data['puzzlesCompleted'] ?? 0;
            final totalTime = data['totalTime'] ?? 0;

            return {
              'userId': doc.id,
              'username': data['username'],
              'score': puzzlesCompleted / (totalTime + 1),
              'puzzlesCompleted': puzzlesCompleted,
              'averageTime': puzzlesCompleted > 0
                  ? totalTime / puzzlesCompleted
                  : 0,
            };
          }).toList();
        });
  }

  // ===== Streak / Badges =====
  static Future<void> updateDailyStreak(String uid) async {
    final doc = FirebaseFirestore.instance.collection("users").doc(uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(doc);
      if (!snap.exists) return;

      final data = snap.data()!;
      final lastActive = (data["lastActiveDate"] as Timestamp?)?.toDate();
      final dailyStreak = data["dailyStreak"] ?? 0;

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      int newStreak = dailyStreak;

      if (lastActive == null) {
        newStreak = 1;
      } else if (_isSameDay(lastActive, today)) {
        return; // already counted today
      } else if (_isSameDay(lastActive, yesterday)) {
        newStreak = dailyStreak + 1;
      } else {
        newStreak = 1; // streak broke
      }

      tx.update(doc, {"lastActiveDate": today, "dailyStreak": newStreak});
    });
  }

  static Future<void> updateBadges(String uid, int dailyStreak) async {
    final doc = FirebaseFirestore.instance.collection("users").doc(uid);

    final earned = {
      "daily3": dailyStreak >= 3,
      "daily5": dailyStreak >= 5,
      "daily10": dailyStreak >= 10,
      "daily30": dailyStreak >= 30,
    };

    await doc.update({"earnedBadges": earned});
  }

  static Future<Map<String, dynamic>> loadUserBadgeData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    return doc.data() ?? {};
  }

  static Future<List<DateTime>?> loadUserActivityDates() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return [];
    final timestamps = (doc.data()?['activityDates'] as List<dynamic>?) ?? [];
    return timestamps.map((ts) => (ts as Timestamp).toDate()).toList();
  }

  static Future<void> saveUserActivityDate(DateTime date) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _users.doc(uid).update({
      'activityDates': FieldValue.arrayUnion([date]),
    });
  }

  static Future<void> clearUserActivityDates() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _users.doc(uid).update({'activityDates': []});
  }

  // ===== Helper =====
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

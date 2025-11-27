
class StreakUtils {
  /// Returns current streak (consecutive days)
  static int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a)); // newest first
    int streak = 1;
    DateTime prev = dates.first;

    for (int i = 1; i < dates.length; i++) {
      if (prev.difference(dates[i]).inDays == 1) {
        streak++;
        prev = dates[i];
      } else if (prev.difference(dates[i]).inDays > 1) {
        break;
      }
    }

    return streak;
  }
}

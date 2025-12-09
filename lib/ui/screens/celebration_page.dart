import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trace_it/providers/badge_provider.dart';
import '../../providers/puzzle_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../models/leaderboard_user.dart';
import 'package:trace_it/core/services/firestore_service.dart';
import 'package:trace_it/core/services/storage_service.dart';
import 'package:trace_it/core/utils/puzzle_generator.dart';

class CelebrationPage extends StatefulWidget {
  const CelebrationPage({super.key});

  @override
  State<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage> {
  late ConfettiController _topController;
  late ConfettiController _bottomController;
  late ConfettiController _leftController;
  late ConfettiController _rightController;

  @override
  void initState() {
    super.initState();

    _topController = ConfettiController(duration: const Duration(seconds: 3));
    _bottomController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _leftController = ConfettiController(duration: const Duration(seconds: 3));
    _rightController = ConfettiController(duration: const Duration(seconds: 3));

    _topController.play();
    _bottomController.play();
    _leftController.play();
    _rightController.play();

    _processPuzzleCompletion();
  }

  Future<void> _processPuzzleCompletion() async {
    // Delay before processing
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final puzzleProvider = context.read<PuzzleProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();
    final badgeProvider = context.read<BadgeProvider>();
    final user = FirebaseAuth.instance.currentUser;

    // Show loading dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    });

    if (user != null) {
      final attempts = puzzleProvider.attempts;
      final elapsedSeconds = puzzleProvider.elapsed.inSeconds;

      await FirestoreService.saveGameResult(user.uid, attempts, elapsedSeconds);

      await FirestoreService.updateDailyStreak(user.uid);

      final badgeData = await FirestoreService.loadUserBadgeData(user.uid);
      badgeProvider.updateFromFirestore(badgeData);

      await StorageService.completePuzzle(attempts, elapsedSeconds);

      final updatedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = updatedDoc.data()!;

      final puzzlesCompleted = (data['puzzlesCompleted'] ?? 0) as int;
      final totalTime = (data['totalTime'] ?? 0) as num;
      final averageTime = puzzlesCompleted > 0
          ? totalTime / puzzlesCompleted
          : 0.0;

      final username = data['username'] ?? user.displayName ?? "Player";

      await FirestoreService.updateLeaderboard(
        userId: user.uid,
        username: username,
        puzzlesCompleted: puzzlesCompleted,
        totalTime: totalTime.toInt(),
      );

      final index = leaderboardProvider.entries.indexWhere(
        (e) => e.userId == user.uid,
      );

      final updatedEntry = LeaderboardEntry(
        userId: user.uid,
        username: username,
        puzzlesCompleted: puzzlesCompleted,
        totalTime: totalTime.toDouble(),
        averageTime: averageTime.toDouble(),
        previousRank: 0,
      );

      if (index >= 0) {
        leaderboardProvider.entries[index] = updatedEntry;
      } else {
        leaderboardProvider.entries.add(updatedEntry);
      }

      leaderboardProvider.entries.sort((a, b) => b.score.compareTo(a.score));

      leaderboardProvider.notifyListeners();
    }

    puzzleProvider.attempts = 0;
    await puzzleProvider.generateNewDifficultPuzzle(
      8,
      PuzzlePathMode.heuristicDFS,
      15,
      context,
    );

    if (mounted) Navigator.pop(context);
    if (mounted) Navigator.pushNamed(context, "/game");
  }

  @override
  void dispose() {
    _topController.dispose();
    _bottomController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PuzzleProvider>(context, listen: false);
    final minutes = provider.elapsed.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = provider.elapsed.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    provider.recordWin();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _topController,
              blastDirection: 3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _bottomController,
              blastDirection: -3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: 0,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: 3.14,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              width: 350,
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/trophy_animation.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "🎉 Congratulations! 🎉",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time: $minutes:$seconds",
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Consumer<PuzzleProvider>(
                    builder: (_, provider, __) {
                      if (provider.currentStreak >= 10) {
                        return Text(
                          "🏆 LEGENDARY STREAK: ${provider.currentStreak}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      if (provider.currentStreak >= 5) {
                        return Text(
                          "🔥🔥 Hot Streak: ${provider.currentStreak}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      if (provider.currentStreak >= 3) {
                        return Text(
                          "🔥 Streak: ${provider.currentStreak}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

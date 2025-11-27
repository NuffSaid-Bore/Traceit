import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/ui/widgets/badge_timeline.dart';
import '../../providers/puzzle_provider.dart';
import 'package:confetti/confetti.dart';

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
    Timer(const Duration(seconds: 4), () {
      Navigator.pop(context);
    });
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

    // Record the win
    provider.recordWin();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Top confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _topController,
              blastDirection: 3.14 / 2, // downward
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          // Bottom confetti
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _bottomController,
              blastDirection: -3.14 / 2, // upward
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          // Left confetti
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: 0, // right
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
          // Right confetti
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: 3.14, // left
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
              width: 300,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Puzzle Completed!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time: $minutes:$seconds",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Consumer<PuzzleProvider>(
                    builder: (_, provider, __) {
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
          Column(children: [BadgeTimeline()]),
        ],
      ),
    );
  }
}

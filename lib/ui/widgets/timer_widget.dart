import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/puzzle_provider.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(builder: (_, provider, __) {
      final minutes = provider.elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = provider.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

      return Text(
        "Time: $minutes:$seconds",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/puzzle_provider.dart';

class AttemptCounter extends StatelessWidget {
  const AttemptCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(builder: (_, provider, __) {
      return Text(
        "Attempt: ${provider.attempts}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/providers/game_state_provider.dart';
import 'package:trace_it/providers/puzzle_provider.dart';
import '../widgets/timer_widget.dart';
import '../widgets/attempt_counter.dart';
import '../widgets/grid_board.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                TimerWidget(),
                AttemptCounter(),
              ],
            ),

            const SizedBox(height: 20),
            const Expanded(child: GridBoard()),

            const SizedBox(height: 20),
            Consumer<PuzzleProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: () {
                    final gameProvider = Provider.of<GameStateProvider>(context, listen: false);
                      gameProvider.incrementAttempts();
                    provider.undo();
                  },
                  child: const Text("Undo"),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

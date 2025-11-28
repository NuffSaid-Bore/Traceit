import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/core/utils/puzzle_generator.dart';
import 'package:trace_it/providers/game_state_provider.dart';
import 'package:trace_it/providers/puzzle_provider.dart';
import 'package:trace_it/ui/widgets/badge_timeline.dart';
import '../widgets/leaderboard_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );

      gameProvider.loadSavedGame().then((_) {
        if (mounted) setState(() => loading = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameStateProvider>(context);
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text("ZIP", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 20),
              LeaderboardWidget(),
              const SizedBox(height: 20),
              BadgeTimeline(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: gameProvider.hasSavedGame
                    ? () {
                        Navigator.pushNamed(context, "/game");
                      }
                    : null,
                child: const Text("Continue"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<PuzzleProvider>();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  await provider.generateNewPuzzle(8, PuzzlePathMode.heuristicDFS, 15);
                  Navigator.pop(context); // remove loading dialog
                  Navigator.pushNamed(context, "/game");
                },
                child: const Text("New Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

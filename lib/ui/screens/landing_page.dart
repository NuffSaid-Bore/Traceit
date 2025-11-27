import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/providers/game_state_provider.dart';
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
    final gameProvider = Provider.of<GameStateProvider>(context, listen: false);
    gameProvider.loadSavedGame().then((_) {
      setState(() => loading = false);
    });
  }


  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameStateProvider>(context);
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("ZIP", style: Theme.of(context).textTheme.headlineLarge),

            const SizedBox(height: 20),
            // Insert leaderboard widget later
            LeaderboardWidget(),
            const Placeholder(fallbackHeight: 120),

            const SizedBox(height: 20),
            // Insert badge timeline
            BadgeTimeline(),
            const Placeholder(fallbackHeight: 60),

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
              onPressed: () => Navigator.pushNamed(context, "/game"),
              child: const Text("New Game"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      () async {
        try {
          await gameProvider.loadSavedGame();
        } catch (e) {
          print("Error: $e");
        } finally {
          if (mounted) setState(() => loading = false);
        }
      }();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    Navigator.pushNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameStateProvider>(
      context,
    ); // listen true!
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.15), // glass morph effect
        elevation: 0,
        title: const Text(
          "Trace...It",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.logout, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: LeaderboardWidget(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: BadgeTimeline(),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                      await provider.generateNewPuzzle(
                        8,
                        PuzzlePathMode.heuristicDFS,
                        15,
                      );
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/game");
                    },
                    child: const Text("New Game"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

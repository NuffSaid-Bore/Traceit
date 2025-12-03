import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trace_it/ui/screens/celebration_page.dart';
import 'package:trace_it/ui/screens/game_page.dart';
import 'package:trace_it/ui/screens/landing_page.dart';
import 'package:trace_it/ui/screens/login.dart';
import 'package:trace_it/ui/screens/sign_up.dart';
import 'package:trace_it/ui/screens/splash_screen.dart';
import 'providers/puzzle_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/game_state_provider.dart';
import 'providers/badge_provider.dart';


class ZipApp extends StatelessWidget {
  const ZipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        // GameStateProvider is created first
        ChangeNotifierProvider(create: (_) => GameStateProvider()),

        // LeaderboardProvider is created second
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),

        // PuzzleProvider depends on LeaderboardProvider
        ChangeNotifierProxyProvider<LeaderboardProvider, PuzzleProvider>(
        create: (_) => PuzzleProvider(leaderboardProvider: null),
        update: (_, leaderboardProvider, previous) {
          previous ??= PuzzleProvider(leaderboardProvider: leaderboardProvider);
          previous.leaderboardProvider = leaderboardProvider;
          return previous;
        },
      ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: "/",
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          "/home": (_) => const LandingPage(),
          "/game": (_) => const GamePage(),
          "/celebrate": (_) => const CelebrationPage(),
        },
      )
      );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_refresh/liquid_pull_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_it/core/services/firestore_service.dart';
import 'package:trace_it/core/utils/puzzle_generator.dart';
import 'package:trace_it/providers/game_state_provider.dart';
import 'package:trace_it/providers/leaderboard_provider.dart';
import 'package:trace_it/providers/puzzle_provider.dart';
import 'package:trace_it/providers/user_provider.dart';
import 'package:trace_it/ui/widgets/badge_timeline.dart';
import '../widgets/leaderboard_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool loading = true;
  bool _showPassword = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<LiquidPullRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullRefreshState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Wait for build to complete so providers exist
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );

      final userProvider = context.read<UserProvider>();

      // Pre-fill username
      _usernameController.text = userProvider.username;

      try {
        await gameProvider.loadSavedGame();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading saved game: $e")));
      }

      if (mounted) setState(() => loading = false);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
  try {
    // 1. Clear any in-memory game state and local Hive storage
    await context.read<GameStateProvider>().clearAllState();

    // 2. Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    // 3. Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // 4. Navigate to login screen
    Navigator.pushReplacementNamed(context, "/login");

  } catch (e, st) {
    print("Logout error: $e");
    print(st);
  }
}


  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      if (!_formKey.currentState!.validate()) return;

      await userProvider.updateProfile(
        newUsername: _usernameController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameStateProvider>(
      context,
    ); // listen true!

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.15),
        elevation: 0,
        title: const Text(
          "Trace...It",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.person,
                        color: Colors.deepPurpleAccent.shade100,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
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
                    child: Icon(
                      Icons.logout,
                      color: Colors.deepPurpleAccent.shade100,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --------------------------- DRAWER ---------------------------
      drawer: Drawer(
        backgroundColor: Colors.deepPurpleAccent.shade100,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              const Text(
                "Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // PROFILE FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter username" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (value) =>
                          value!.length < 6 ? "Minimum 6 characters" : null,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text("Update Profile"),
                          ),
                  ],
                ),
              ),

              const Divider(height: 20, color: Colors.black),
              Card(
                color: Colors.deepPurpleAccent.shade100,
                semanticContainer: true,
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  splashColor: Colors.deepPurpleAccent[500],
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),

      // --------------------------------------------------------------
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --------------------- LEADERBOARD SECTION ----------------------
            Expanded(
              flex: 2,
              child: LiquidPullRefresh(
                heightLoader: 150,
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  try {
                    await context
                        .read<LeaderboardProvider>()
                        .refreshLeaderboard();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Leaderboard refresh error: $e",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                },
                color: Colors.deepPurpleAccent,
                backgroundColor: Colors.deepPurpleAccent.shade100,
                showChildOpacityTransition: false,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: LeaderboardWidget(),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --------------------- BADGE TIMELINE ----------------------
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: BadgeTimeline(),
            ),

            const SizedBox(height: 20),

            // --------------------- BUTTONS ----------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: gameProvider.hasSavedGame
                      ? () => Navigator.pushNamed(context, "/game")
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
                    provider.currentStreak = 0;

                    await provider.generateNewPuzzle(
                      8,
                      PuzzlePathMode.heuristicDFS,
                      15,
                      context,
                    );

                    if (mounted) Navigator.pop(context);
                    Navigator.pushNamed(context, "/game");
                  },
                  child: const Text("New Game"),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

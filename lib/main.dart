import 'package:demo/providers/auth_provider.dart' as auth;
import 'package:demo/providers/game_provider.dart';
import 'package:demo/providers/history_provider.dart';
import 'package:demo/providers/player_provider.dart';
import 'package:demo/screens/game_board_screen.dart';
import 'package:demo/screens/login_screen.dart';
import 'package:demo/screens/match_history_screen.dart';
import 'package:demo/screens/player_entry_screen.dart';
import 'package:demo/screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Optimize Firestore to reduce storage usage
  // Use memory-only cache instead of disk persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // Disable disk persistence to save storage
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Tic Tac Toe',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/player-entry': (context) => const PlayerEntryScreen(),
          '/game': (context) => const GameBoardScreen(),
          '/history': (context) => const MatchHistoryScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const PlayerEntryScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

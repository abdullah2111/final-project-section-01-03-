import 'package:demo/models/game_models.dart';
import 'package:demo/services/game_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ScoreProvider extends ChangeNotifier {
  int _player1Wins = 0;
  int _player2Wins = 0;
  int _ties = 0;

  int get player1Wins => _player1Wins;
  int get player2Wins => _player2Wins;
  int get ties => _ties;

  void incrementPlayer1Wins() {
    _player1Wins++;
    notifyListeners();
  }

  void incrementPlayer2Wins() {
    _player2Wins++;
    notifyListeners();
  }

  void incrementTies() {
    _ties++;
    notifyListeners();
  }

  void resetScores() {
    _player1Wins = 0;
    _player2Wins = 0;
    _ties = 0;
    notifyListeners();
  }
}

class HistoryProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  List<Match> _matches = [];
  StreamSubscription<List<Match>>? _matchesSubscription;

  List<Match> get matches => _matches;

  HistoryProvider() {
    loadMatches();
  }

  void loadMatches() {
    // Cancel previous subscription to prevent memory leaks
    _matchesSubscription?.cancel();
    
    _matchesSubscription = _gameService.getMatchHistory().listen((matches) {
      _matches = matches;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Clean up the stream subscription when provider is disposed
    _matchesSubscription?.cancel();
    super.dispose();
  }
}

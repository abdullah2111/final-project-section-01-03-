import 'package:demo/models/game_models.dart';
import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();

  GameState get gameState => _gameState;

  void makeMove(int index) {
    if (_gameState.board[index].isEmpty && !_gameState.gameOver) {
      _gameState.makeMove(index);
      notifyListeners();
    }
  }

  void resetGame() {
    _gameState = GameState();
    notifyListeners();
  }

  void setGameState(GameState gameState) {
    _gameState = gameState;
    notifyListeners();
  }
}

import 'package:demo/models/game_models.dart';
import 'package:flutter/material.dart';

/// Provider for managing game state across the app
///
/// This class holds the current game data and notifies all listeners
/// when data changes.
///
/// Key methods:
/// - makeMove(index) - Player clicks a cell
/// - resetGame() - Clear board for new game
/// - setGameState(gameState) - Update entire game state
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();

  GameState get gameState => _gameState;

  /// Player taps a cell to place their symbol
  ///
  /// Example:
  /// ```dart
  /// gameProvider.makeMove(4); // Player taps center cell
  /// ```
  void makeMove(int index) {
    if (_gameState.board[index].isEmpty && !_gameState.gameOver) {
      _gameState.makeMove(index);
      notifyListeners(); // Tell UI to rebuild
    }
  }

  /// Reset the board for a new game
  ///
  /// Example:
  /// ```dart
  /// gameProvider.resetGame();
  /// ```
  void resetGame() {
    _gameState = GameState();
    notifyListeners(); // Tell UI to rebuild
  }

  /// Update the entire game state
  ///
  /// Used when loading a saved game or updating externally
  void setGameState(GameState gameState) {
    _gameState = gameState;
    notifyListeners(); // Tell UI to rebuild
  }
}

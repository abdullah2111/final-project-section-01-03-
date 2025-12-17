import 'package:demo/models/game_models.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  late Player _player1;
  late Player _player2;

  Player get player1 => _player1;
  Player get player2 => _player2;

  PlayerProvider() {
    _player1 = Player(name: '', symbol: 'X');
    _player2 = Player(name: '', symbol: 'O');
  }

  void setPlayers(Player player1, Player player2) {
    _player1 = player1;
    _player2 = player2;
    notifyListeners();
  }

  void switchPlayers() {
    final temp = _player1;
    _player1 = _player2;
    _player2 = temp;
    notifyListeners();
  }

  Player getCurrentPlayer(String symbol) {
    return symbol == 'X' ? _player1 : _player2;
  }
}

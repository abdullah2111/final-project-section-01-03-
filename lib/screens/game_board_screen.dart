import 'package:flutter/material.dart';
import 'package:demo/models/game_models.dart';
import 'package:demo/services/game_service.dart';
class GameBoardScreen extends StatefulWidget {
  final Player player1;
  final Player player2;

  const GameBoardScreen({
    Key? key,
    required this.player1,
    required this.player2,
  }) : super(key: key);

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}
class _GameBoardScreenState extends State<GameBoardScreen> {
  late GameState _gameState;
  late Player _currentPlayerX;
  late Player _currentPlayerO;
  int _player1Wins = 0;
  int _player2Wins = 0;
  int _ties = 0;
  final GameService _gameService = GameService();
  bool _isSaving = false;
@override
  void initState() {
    super.initState();
    _currentPlayerX = widget.player1;
    _currentPlayerO = widget.player2;
    _gameState = GameState();
  }
  void _onCellTapped(int index) {
    if (!_gameState.gameOver && _gameState.board[index].isEmpty) {
      setState(() {
        _gameState.makeMove(index);
      });

      if (_gameState.gameOver) {
        _showGameOverDialog();
      }
    }
  }
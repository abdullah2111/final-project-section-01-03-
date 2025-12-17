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
  void _showGameOverDialog() {
    String title;
    String message;

    if (_gameState.winner == 'tie') {
      title = "It's a Tie!";
      message = 'Both players played well!';
      _ties++;
    } else {
      final winner = _gameState.winner == 'X'
          ? _currentPlayerX
          : _currentPlayerO;
      title = '${winner.name} Wins!';
      message = 'Congratulations!';

      if (_gameState.winner == 'X') {
        _player1Wins++;
      } else {
        _player2Wins++;
      }
    }
 _saveMatch();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _switchPlayers();
              _resetGame();
            },
            child: const Text('Switch Players'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToHistory();
            },
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }
  Future<void> _saveMatch() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final match = Match(
        player1Name: _currentPlayerX.name,
        player2Name: _currentPlayerO.name,
        winner: _gameState.winner ?? 'tie',
        board: _gameState.board,
        date: DateTime.now(),
        player1Symbol: 'X',
        player2Symbol: 'O',
      );
      await _gameService.saveMatch(match);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving match: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }
void _resetGame() {
    setState(() {
      _gameState.reset();
    });
  }

  void _switchPlayers() {
    setState(() {
      final temp = _currentPlayerX;
      _currentPlayerX = _currentPlayerO;
      _currentPlayerO = temp;
      _gameState.reset();
    });
  }
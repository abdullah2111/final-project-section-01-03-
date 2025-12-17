import 'package:demo/models/game_models.dart';
import 'package:demo/providers/game_provider.dart';
import 'package:demo/providers/history_provider.dart';
import 'package:demo/providers/player_provider.dart';
import 'package:demo/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({Key? key}) : super(key: key);

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  final GameService _gameService = GameService();
  bool _isSaving = false;

  void _onCellTapped(int index) {
    final gameProvider = context.read<GameProvider>();
    final gameState = gameProvider.gameState;

    if (!gameState.gameOver && gameState.board[index].isEmpty) {
      gameProvider.makeMove(index);

      if (gameState.gameOver) {
        _showGameOverDialog();
      }
    }
  }

  void _showGameOverDialog() {
    String title;
    String message;
    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();
    final scoreProvider = context.read<ScoreProvider>();

    final gameState = gameProvider.gameState;

    if (gameState.winner == 'tie') {
      title = "It's a Tie!";
      message = 'Both players played well!';
      scoreProvider.incrementTies();
    } else {
      final winner = gameState.winner == 'X'
          ? playerProvider.player1
          : playerProvider.player2;
      title = '${winner.name} Wins!';
      message = 'Congratulations!';

      if (gameState.winner == 'X') {
        scoreProvider.incrementPlayer1Wins();
      } else {
        scoreProvider.incrementPlayer2Wins();
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
      final gameProvider = context.read<GameProvider>();
      final playerProvider = context.read<PlayerProvider>();
      final gameState = gameProvider.gameState;

      final match = Match(
        player1Name: playerProvider.player1.name,
        player2Name: playerProvider.player2.name,
        winner: gameState.winner ?? 'tie',
        board: gameState.board,
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
    context.read<GameProvider>().resetGame();
  }

  void _switchPlayers() {
    context.read<PlayerProvider>().switchPlayers();
    context.read<GameProvider>().resetGame();
  }

  void _goToHistory() {
    Navigator.of(context).pushNamed('/history');
  }

  void _goToHome() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Color _getCellColor(int index, GameState gameState) {
    final cell = gameState.board[index];
    if (cell == 'X') {
      return Colors.blue.withOpacity(0.2);
    } else if (cell == 'O') {
      return Colors.red.withOpacity(0.2);
    }
    return Colors.grey.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goToHome,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _goToHistory),
        ],
      ),
      body: Consumer3<GameProvider, PlayerProvider, ScoreProvider>(
        builder: (context, gameProvider, playerProvider, scoreProvider, _) {
          final gameState = gameProvider.gameState;
          final player1 = playerProvider.player1;
          final player2 = playerProvider.player2;
          final currentPlayer = gameState.currentPlayer == 'X'
              ? player1
              : player2;
          final isXTurn = gameState.currentPlayer == 'X';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Scoreboard
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreWidget(
                            player1.name,
                            scoreProvider.player1Wins,
                            Colors.blue,
                          ),
                          _buildScoreWidget(
                            'Ties',
                            scoreProvider.ties,
                            Colors.grey,
                          ),
                          _buildScoreWidget(
                            player2.name,
                            scoreProvider.player2Wins,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current turn indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isXTurn
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isXTurn ? Colors.blue : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Current Turn',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentPlayer.name} (${currentPlayer.symbol})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isXTurn ? Colors.blue : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Game board
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onCellTapped(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getCellColor(index, gameState),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gameState.board[index],
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: gameState.board[index] == 'X'
                                      ? Colors.blue
                                      : gameState.board[index] == 'O'
                                      ? Colors.red
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Game status
                  if (gameState.gameOver)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        gameState.winner == 'tie'
                            ? "It's a Tie!"
                            : '${gameState.winner == 'X' ? player1.name : player2.name} Wins!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        "Game in Progress",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _resetGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reset Board',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _switchPlayers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Switch Players',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _goToHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreWidget(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

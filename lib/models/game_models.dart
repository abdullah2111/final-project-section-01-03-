import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String name;
  final String symbol; // 'X' or 'O'

  Player({required this.name, required this.symbol});
}

class GameState {
  List<String> board; // Empty string or 'X' or 'O'
  String currentPlayer; // 'X' or 'O'
  bool gameOver;
  String? winner; // null, 'X', 'O', or 'tie'

  GameState({
    List<String>? board,
    this.currentPlayer = 'X',
    this.gameOver = false,
    this.winner,
  }) : board = board ?? List.filled(9, '');

  GameState copy() {
    return GameState(
      board: List.from(board),
      currentPlayer: currentPlayer,
      gameOver: gameOver,
      winner: winner,
    );
  }

  void reset() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    gameOver = false;
    winner = null;
  }

  bool makeMove(int index) {
    if (board[index].isNotEmpty || gameOver) return false;

    board[index] = currentPlayer;
    _checkGameStatus();

    if (!gameOver) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }

    return true;
  }

  void _checkGameStatus() {
    // Check win conditions
    const List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        gameOver = true;
        return;
      }
    }

    // Check tie
    if (board.every((cell) => cell.isNotEmpty)) {
      winner = 'tie';
      gameOver = true;
    }
  }
}

class Match {
  final String? matchId;
  final String player1Name;
  final String player2Name;
  final String winner; // 'X', 'O', or 'tie'
  final List<String> board;
  final DateTime date;
  final String player1Symbol;
  final String player2Symbol;

  Match({
    this.matchId,
    required this.player1Name,
    required this.player2Name,
    required this.winner,
    required this.board,
    required this.date,
    this.player1Symbol = 'X',
    this.player2Symbol = 'O',
  });

  Map<String, dynamic> toMap() {
    return {
      'player1Name': player1Name,
      'player2Name': player2Name,
      'winner': winner,
      'board': board,
      'date': Timestamp.fromDate(date),
      'player1Symbol': player1Symbol,
      'player2Symbol': player2Symbol,
    };
  }

  factory Match.fromMap(Map<String, dynamic>? map, String docId) {
    if (map == null) {
      // Return default match for null data
      return Match(
        matchId: docId,
        player1Name: 'Unknown',
        player2Name: 'Unknown',
        winner: 'tie',
        board: List.filled(9, ''),
        date: DateTime.now(),
        player1Symbol: 'X',
        player2Symbol: 'O',
      );
    }

    return Match(
      matchId: docId,
      player1Name: (map['player1Name'] as String?) ?? 'Unknown',
      player2Name: (map['player2Name'] as String?) ?? 'Unknown',
      winner: (map['winner'] as String?) ?? 'tie',
      board: List<String>.from((map['board'] as List?) ?? []),
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      player1Symbol: (map['player1Symbol'] as String?) ?? 'X',
      player2Symbol: (map['player2Symbol'] as String?) ?? 'O',
    );
  }
}

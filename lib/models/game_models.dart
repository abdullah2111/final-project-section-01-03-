import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple data class representing a player
///
/// Example:
/// ```dart
/// Player player1 = Player(name: "Ali", symbol: 'X');
/// ```
class Player {
  final String name;
  final String symbol; // 'X' or 'O'

  Player({required this.name, required this.symbol});
}

/// Manages the current state of a Tic Tac Toe game
///
/// The board has 9 positions:
/// ```
/// 0 | 1 | 2
/// ---------
/// 3 | 4 | 5
/// ---------
/// 6 | 7 | 8
/// ```
///
/// Example:
/// ```dart
/// GameState game = GameState();
/// game.makeMove(4); // X plays center
/// game.makeMove(0); // O plays top-left
/// ```
class GameState {
  List<String> board; // Empty string or 'X' or 'O'
  String currentPlayer; // 'X' or 'O' - whose turn?
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

  /// Place current player's symbol at the given position
  /// Returns true if move was successful, false if invalid
  bool makeMove(int index) {
    if (board[index].isNotEmpty || gameOver) return false;

    board[index] = currentPlayer;
    _checkGameStatus();

    if (!gameOver) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }

    return true;
  }

  /// Check if game has ended (someone won or tie)
  void _checkGameStatus() {
    // 8 ways to win: 3 rows, 3 columns, 2 diagonals
    const List<List<int>> winPatterns = [
      [0, 1, 2], // top row
      [3, 4, 5], // middle row
      [6, 7, 8], // bottom row
      [0, 3, 6], // left column
      [1, 4, 7], // middle column
      [2, 5, 8], // right column
      [0, 4, 8], // diagonal (top-left to bottom-right)
      [2, 4, 6], // diagonal (top-right to bottom-left)
    ];

    // Check each winning pattern
    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        gameOver = true;
        return;
      }
    }

    // Check tie: all cells filled and no winner
    if (board.every((cell) => cell.isNotEmpty)) {
      winner = 'tie';
      gameOver = true;
    }
  }
}

/// Represents a completed game/match
/// This is saved to Firebase after each game ends
///
/// Example:
/// ```dart
/// Match match = Match(
///   player1Name: "Ali",
///   player2Name: "Ahmed",
///   winner: "X",
///   board: ["X", "O", "X", ...],
///   date: DateTime.now(),
///   userEmail: "user@example.com",
/// );
/// await gameService.saveMatch(match);
/// ```
class Match {
  final String? matchId; // Firebase document ID
  final String player1Name; // First player's name
  final String player2Name; // Second player's name
  final String winner; // 'X', 'O', or 'tie'
  final List<String> board; // Final board state (9 cells)
  final DateTime date; // When the match was played
  final String player1Symbol; // 'X'
  final String player2Symbol; // 'O'
  final String? userEmail; // Email of user who played

  Match({
    this.matchId,
    required this.player1Name,
    required this.player2Name,
    required this.winner,
    required this.board,
    required this.date,
    this.player1Symbol = 'X',
    this.player2Symbol = 'O',
    this.userEmail,
  });

  /// Convert Match to Map for Firebase storage
  /// Firebase doesn't understand Dart objects, only maps
  Map<String, dynamic> toMap() {
    return {
      'player1Name': player1Name,
      'player2Name': player2Name,
      'winner': winner,
      'board': board,
      'date': Timestamp.fromDate(
        date,
      ), // Convert DateTime to Firebase Timestamp
      'player1Symbol': player1Symbol,
      'player2Symbol': player2Symbol,
      'userEmail': userEmail,
    };
  }

  /// Create Match object from Firebase data
  /// Firebase returns Map, we need to convert to Match object
  factory Match.fromMap(Map<String, dynamic>? map, String docId) {
    if (map == null) {
      return Match(
        matchId: docId,
        player1Name: 'Unknown',
        player2Name: 'Unknown',
        winner: 'tie',
        board: List.filled(9, ''),
        date: DateTime.now(),
        player1Symbol: 'X',
        player2Symbol: 'O',
        userEmail: null,
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
      userEmail: (map['userEmail'] as String?),
    );
  }
}

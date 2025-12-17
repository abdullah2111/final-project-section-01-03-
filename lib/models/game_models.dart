class Player {
  final String name;
  final String symbol; // 'X' or 'O'

  Player({required this.name, required this.symbol});
}

class GameState {
  List<String> board;
  String currentPlayer;

  GameState({List<String>? board, this.currentPlayer = 'X'})
    : board = board ?? List.filled(9, '');
}

class Match {
  final String? matchId;
  final String player1Name;
  final String player2Name;

  Match({this.matchId, required this.player1Name, required this.player2Name});
}

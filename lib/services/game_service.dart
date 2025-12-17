import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/game_models.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMatch(Match match) async {
    try {
      print(
        'DEBUG: Attempting to save match: ${match.player1Name} vs ${match.player2Name}',
      );
      final docRef = await _firestore.collection('matches').add(match.toMap());
      print('DEBUG: Match saved successfully with ID: ${docRef.id}');
    } catch (e) {
      print('DEBUG: Error saving match: $e');
      rethrow;
    }
  }

  Stream<List<Match>> getMatchHistory() {
    return _firestore
        .collection('matches')
        .orderBy('date', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          print(
            'DEBUG: Received snapshot with ${snapshot.docs.length} documents',
          );
          final matches = <Match>[];
          for (var doc in snapshot.docs) {
            if (!doc.exists) continue;
            try {
              matches.add(Match.fromMap(doc.data(), doc.id));
              print('DEBUG: Parsed match: ${doc.id}');
            } catch (e) {
              print('DEBUG: Failed to parse document ${doc.id}: $e');
              // Skip documents that fail to parse
            }
          }
          // Already sorted by Firestore, no need to sort again
          print('DEBUG: Returning ${matches.length} matches');
          return matches;
        })
        .handleError((error) {
          print('DEBUG: Stream error: $error');
          return [];
        });
  }

  // Fallback Future-based method
  Future<List<Match>> getMatchHistoryFuture() async {
    try {
      print('DEBUG: Fetching match history (Future-based)');
      final snapshot = await _firestore
          .collection('matches')
          .orderBy('date', descending: true)
          .limit(100)
          .get();
      print('DEBUG: Got ${snapshot.docs.length} documents from Firestore');

      final matches = <Match>[];
      for (var doc in snapshot.docs) {
        if (!doc.exists) continue;
        try {
          matches.add(Match.fromMap(doc.data(), doc.id));
          print('DEBUG: Parsed match: ${doc.id}');
        } catch (e) {
          print('DEBUG: Failed to parse document ${doc.id}: $e');
          // Skip
        }
      }
      // Already sorted by Firestore
      print('DEBUG: Returning ${matches.length} matches');
      return matches;
    } catch (e) {
      print('DEBUG: Error fetching history: $e');
      return [];
    }
  }

  Future<Map<String, int>> getPlayerStats(String playerName) async {
    try {
      // Fetch all matches for this player (both as player1 and player2)
      final snapshot = await _firestore.collection('matches').limit(100).get();

      int playerWins = 0;
      int playerTies = 0;

      for (var doc in snapshot.docs) {
        try {
          final match = Match.fromMap(doc.data(), doc.id);

          // Check if player is in this match
          if (match.player1Name == playerName ||
              match.player2Name == playerName) {
            if (match.winner == 'tie') {
              playerTies++;
            } else if (match.winner == 'X' && match.player1Name == playerName) {
              playerWins++;
            } else if (match.winner == 'O' && match.player2Name == playerName) {
              playerWins++;
            }
          }
        } catch (e) {
          // Skip documents with parsing errors
        }
      }

      return {'wins': playerWins, 'ties': playerTies};
    } catch (e) {
      return {'wins': 0, 'ties': 0};
    }
  }
}

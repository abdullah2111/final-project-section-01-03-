import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/game_models.dart';

/// Service class for all Firebase Firestore operations
///
/// This handles CRUD operations:
/// - CREATE: saveMatch() - Add new game to database
/// - READ: getMatchHistory() - Get all games from database
/// - UPDATE: Not needed (games can't change)
/// - DELETE: Not needed (we keep history)
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// CREATE: Save a completed match to Firebase
  ///
  /// Example:
  /// ```dart
  /// Match match = Match(...);
  /// await gameService.saveMatch(match);
  /// ```
  Future<void> saveMatch(Match match) async {
    try {
      print(
        'DEBUG: Attempting to save match: ${match.player1Name} vs ${match.player2Name}',
      );
      // Add new document to 'matches' collection
      // Firebase auto-generates an ID for each match
      final docRef = await _firestore.collection('matches').add(match.toMap());
      print('DEBUG: Match saved successfully with ID: ${docRef.id}');
    } catch (e) {
      print('DEBUG: Error saving match: $e');
      rethrow;
    }
  }

  /// READ: Get all matches from Firebase as a real-time stream
  ///
  /// Returns a Stream that automatically updates when new matches are added
  /// Limited to last 50 games to reduce memory usage
  ///
  /// Example:
  /// ```dart
  /// gameService.getMatchHistory().listen((matches) {
  ///   print('Got ${matches.length} matches');
  /// });
  /// ```
  Stream<List<Match>> getMatchHistory() {
    return _firestore
        .collection('matches')
        .orderBy('date', descending: true) // Newest first
        .limit(50) // Reduced from 100 to 50 to save memory
        .snapshots()
        .map((snapshot) {
          print(
            'DEBUG: Received snapshot with ${snapshot.docs.length} documents',
          );
          final matches = <Match>[];
          for (var doc in snapshot.docs) {
            if (!doc.exists) continue;
            try {
              // Convert Firebase document to Match object
              matches.add(Match.fromMap(doc.data(), doc.id));
              print('DEBUG: Parsed match: ${doc.id}');
            } catch (e) {
              print('DEBUG: Failed to parse document ${doc.id}: $e');
              // Skip documents that fail to parse
            }
          }
          print('DEBUG: Returning ${matches.length} matches');
          return matches;
        })
        .handleError((error) {
          print('DEBUG: Stream error: $error');
          return [];
        });
  }

  /// Fallback Future-based method (if Stream doesn't work)
  Future<List<Match>> getMatchHistoryFuture() async {
    try {
      print('DEBUG: Fetching match history (Future-based)');
      final snapshot = await _firestore
          .collection('matches')
          .orderBy('date', descending: true)
          .limit(50) // Reduced from 100 to 50 to save memory
          .get();
      print('DEBUG: Got ${snapshot.docs.length} documents from Firestore');

      final matchesList = <Match>[];
      for (var doc in snapshot.docs) {
        if (!doc.exists) continue;
        try {
          matchesList.add(Match.fromMap(doc.data(), doc.id));
        } catch (e) {
          print('DEBUG: Failed to parse document ${doc.id}: $e');
        }
      }
      return matchesList;
    } catch (e) {
      print('DEBUG: Error fetching history: $e');
      return [];
    }
  }
}

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

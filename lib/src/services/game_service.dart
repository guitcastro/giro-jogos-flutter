import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'games';

  // Get all active games
  Stream<List<Game>> getActiveGames() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Game.fromJson(data);
      }).toList();
    });
  }

  // Get game by ID
  Future<Game?> getGameById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Game.fromJson(data);
  }

  // Create new game (admin only)
  Future<String> createGame(Game game) async {
    final docRef = await _firestore.collection(_collection).add(game.toJson());
    return docRef.id;
  }

  // Update game (admin only)
  Future<void> updateGame(String id, Game game) async {
    await _firestore.collection(_collection).doc(id).update(game.toJson());
  }

  // Delete game (admin only)
  Future<void> deleteGame(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Search games by title
  Stream<List<Game>> searchGames(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Game.fromJson(data);
          }).toList();
        });
  }
}

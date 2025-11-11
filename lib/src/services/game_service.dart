/*
 * This file is part of Giro Jogos.
 * 
 * Giro Jogos is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Giro Jogos is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with Giro Jogos. If not, see <https://www.gnu.org/licenses/>.
 */

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

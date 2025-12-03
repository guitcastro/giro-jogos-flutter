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

class TermsService {
  static const String termsYear = '2025';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _docRef(
    String uid, {
    String year = termsYear,
  }) {
    return _db.collection('users').doc(uid).collection('terms').doc(year);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> termsDocStream(
    String uid, {
    String year = termsYear,
  }) {
    return _docRef(uid, year: year).snapshots();
  }

  Future<bool> hasAccepted(String uid, {String year = termsYear}) async {
    final snap = await _docRef(uid, year: year).get();
    return snap.exists;
  }

  Future<void> acceptTerms({
    required String uid,
    required String name,
    required String document,
    required String emergencyName,
    required String emergencyPhone,
    String year = termsYear,
  }) async {
    final ref = _docRef(uid, year: year);
    await ref.set({
      'year': year,
      'name': name,
      'document': document,
      'emergencyName': emergencyName,
      'emergencyPhone': emergencyPhone,
      'acceptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));
  }
}

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

class TermsAcceptance {
  final String year;
  final String name;
  final String document;
  final String emergencyName;
  final String emergencyPhone;
  final DateTime? acceptedAt;

  const TermsAcceptance({
    required this.year,
    required this.name,
    required this.document,
    required this.emergencyName,
    required this.emergencyPhone,
    this.acceptedAt,
  });

  factory TermsAcceptance.fromFirestore(Map<String, dynamic> data) {
    return TermsAcceptance(
      year: data['year'] as String,
      name: data['name'] as String,
      document: data['document'] as String,
      emergencyName: data['emergencyName'] as String,
      emergencyPhone: data['emergencyPhone'] as String,
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Abstract interface for terms acceptance service.
abstract class TermsService {
  static const String termsYear = '2025';

  Stream<TermsAcceptance?> termsStream(
    String uid, {
    String year = termsYear,
  });

  Future<bool> hasAccepted(String uid, {String year = termsYear});

  Future<void> acceptTerms({
    required String uid,
    required String name,
    required String document,
    required String emergencyName,
    required String emergencyPhone,
    String year = termsYear,
  });
}

/// Firestore implementation of TermsService.
class FirestoreTermsService implements TermsService {
  DocumentReference<Map<String, dynamic>> _docRef(
    String uid, {
    String year = TermsService.termsYear,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('terms')
        .doc(year);
  }

  @override
  Stream<TermsAcceptance?> termsStream(
    String uid, {
    String year = TermsService.termsYear,
  }) {
    return _docRef(uid, year: year).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return TermsAcceptance.fromFirestore(snap.data()!);
    });
  }

  @override
  Future<bool> hasAccepted(String uid,
      {String year = TermsService.termsYear}) async {
    final snap = await _docRef(uid, year: year).get();
    return snap.exists;
  }

  @override
  Future<void> acceptTerms({
    required String uid,
    required String name,
    required String document,
    required String emergencyName,
    required String emergencyPhone,
    String year = TermsService.termsYear,
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

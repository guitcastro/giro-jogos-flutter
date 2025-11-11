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

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/challenge_submission.dart';

class MediaUploadService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  MediaUploadService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Seleciona uma imagem da galeria
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
    } catch (e) {
      throw Exception('Erro ao selecionar imagem: $e');
    }
  }

  /// Seleciona um vídeo da galeria
  Future<XFile?> pickVideoFromGallery() async {
    try {
      return await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limite de 5 minutos
      );
    } catch (e) {
      throw Exception('Erro ao selecionar vídeo: $e');
    }
  }

  /// Faz upload do arquivo para o Firebase Storage
  Future<String> _uploadFile(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(file.path));

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload do arquivo: $e');
    }
  }

  /// Submete uma foto para um desafio
  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required String duoInviteCode,
    required XFile imageFile,
    String? description,
  }) async {
    try {
      final timestamp = DateTime.now();
      final fileName =
          '${duoId}_${challengeId}_${timestamp.millisecondsSinceEpoch}.jpg';
      final path = 'challenges/$challengeId/$fileName';

      final downloadUrl = await _uploadFile(imageFile, path);

      final submission = ChallengeSubmission(
        id: '', // Will be set by Firestore
        challengeId: challengeId,
        duoId: duoId,
        duoInviteCode: duoInviteCode,
        mediaUrl: downloadUrl,
        mediaType: MediaType.image,
        submissionTime: timestamp,
        description: description,
      );

      final docRef = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('submissions')
          .add(submission.toMap());

      return submission.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erro ao submeter imagem: $e');
    }
  }

  /// Submete um vídeo para um desafio
  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required String duoInviteCode,
    required XFile videoFile,
    String? description,
  }) async {
    try {
      final timestamp = DateTime.now();
      final fileName =
          '${duoId}_${challengeId}_${timestamp.millisecondsSinceEpoch}.mp4';
      final path = 'challenges/$challengeId/$fileName';

      final downloadUrl = await _uploadFile(videoFile, path);

      final submission = ChallengeSubmission(
        id: '', // Will be set by Firestore
        challengeId: challengeId,
        duoId: duoId,
        duoInviteCode: duoInviteCode,
        mediaUrl: downloadUrl,
        mediaType: MediaType.video,
        submissionTime: timestamp,
        description: description,
      );

      final docRef = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('submissions')
          .add(submission.toMap());

      return submission.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erro ao submeter vídeo: $e');
    }
  }

  /// Obtém todas as submissões de um desafio específico para uma dupla
  Stream<List<ChallengeSubmission>> getSubmissionsStream({
    required String challengeId,
    required String duoId,
  }) {
    return _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('submissions')
        .where('duoId', isEqualTo: duoId)
        .orderBy('submissionTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeSubmission.fromFirestore(doc))
            .toList());
  }

  /// Deleta uma submissão
  Future<void> deleteSubmission({
    required String challengeId,
    required String submissionId,
  }) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('submissions')
          .doc(submissionId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar submissão: $e');
    }
  }
}

extension ChallengeSubmissionCopyWith on ChallengeSubmission {
  ChallengeSubmission copyWith({
    String? id,
    String? challengeId,
    String? duoId,
    String? duoInviteCode,
    String? mediaUrl,
    MediaType? mediaType,
    DateTime? submissionTime,
    String? description,
  }) {
    return ChallengeSubmission(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      duoId: duoId ?? this.duoId,
      duoInviteCode: duoInviteCode ?? this.duoInviteCode,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      submissionTime: submissionTime ?? this.submissionTime,
      description: description ?? this.description,
    );
  }
}

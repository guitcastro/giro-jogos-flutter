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
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Try to extract the file extension (including the leading dot) from XFile
  String _fileExtension(XFile file) {
    try {
      final name = file.name.isNotEmpty ? file.name : file.path;
      final idx = name.lastIndexOf('.');
      if (idx == -1 || idx == name.length - 1) return '';
      return name.substring(idx).toLowerCase();
    } catch (_) {
      // Fallback: try to parse path
      final idx = file.path.lastIndexOf('.');
      if (idx == -1 || idx == file.path.length - 1) return '';
      return file.path.substring(idx).toLowerCase();
    }
  }

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
  Future<String> _uploadFile(XFile file, String path,
      {Map<String, String>? customMetadata}) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List bytes = await file.readAsBytes();
        String contentType = 'application/octet-stream';
        final lower = path.toLowerCase();
        if (lower.endsWith('.mp4')) {
          contentType = 'video/mp4';
        } else if (lower.endsWith('.mov')) {
          contentType = 'video/quicktime';
        } else if (lower.endsWith('.png')) {
          contentType = 'image/png';
        } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        }

        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: contentType,
            customMetadata: customMetadata,
          ),
        );
      } else {
        uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(
            contentType: null,
            customMetadata: customMetadata,
          ),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception(
            'Erro ao fazer upload do arquivo: FirebaseException(code=${e.code}, message=${e.message})');
      }

      if (e is UnsupportedError) {
        throw Exception(
            'Erro ao fazer upload do arquivo: Unsupported operation detected (running on web?). Verifique se está usando `kIsWeb` e use `putData` para uploads no web. Detalhes: $e');
      }

      throw Exception('Erro ao fazer upload do arquivo: $e');
    }
  }

  /// Submete uma foto para um desafio
  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required XFile imageFile,
    String? description,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Ensure user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Reserve a Firestore document id so we can name the file with it
      final docRef = _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('submissions')
          .doc();
      final submissionId = docRef.id;

      var ext = _fileExtension(imageFile);
      if (ext.isEmpty) ext = '.jpg';
      final fileName = '$submissionId$ext';
      final path = 'challenges/$challengeId/duos/$duoId/$fileName';

      // Prepare metadata to be checked by storage rules
      final metadata = <String, String>{
        'uploaderUid': currentUser.uid,
        'duoId': duoId,
        'challengeId': challengeId,
        'submissionId': submissionId,
      };

      final downloadUrl =
          await _uploadFile(imageFile, path, customMetadata: metadata);

      final submission = ChallengeSubmission(
        id: submissionId,
        challengeId: challengeId,
        duoId: duoId,
        uploaderUid: currentUser.uid,
        mediaUrl: downloadUrl,
        mediaType: MediaType.image,
        submissionTime: timestamp,
        description: description,
      );

      await docRef.set(submission.toMap());

      return submission;
    } catch (e) {
      throw Exception('Erro ao submeter imagem: $e');
    }
  }

  /// Submete um vídeo para um desafio
  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required XFile videoFile,
    String? description,
  }) async {
    try {
      final timestamp = DateTime.now();

      // Ensure user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Reserve a Firestore document id so we can name the file with it
      final docRef = _firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('submissions')
          .doc();
      final submissionId = docRef.id;

      var ext = _fileExtension(videoFile);
      if (ext.isEmpty) ext = '.mp4';
      final fileName = '$submissionId$ext';
      final path = 'challenges/$challengeId/duos/$duoId/$fileName';

      final metadata = <String, String>{
        'uploaderUid': currentUser.uid,
        'duoId': duoId,
        'challengeId': challengeId,
        'submissionId': submissionId,
      };

      final downloadUrl =
          await _uploadFile(videoFile, path, customMetadata: metadata);

      final submission = ChallengeSubmission(
        id: submissionId,
        challengeId: challengeId,
        duoId: duoId,
        uploaderUid: currentUser.uid,
        mediaUrl: downloadUrl,
        mediaType: MediaType.video,
        submissionTime: timestamp,
        description: description,
      );

      await docRef.set(submission.toMap());

      return submission;
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
    String? uploaderUid,
    String? mediaUrl,
    MediaType? mediaType,
    DateTime? submissionTime,
    String? description,
  }) {
    return ChallengeSubmission(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      duoId: duoId ?? this.duoId,
      uploaderUid: uploaderUid ?? this.uploaderUid,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      submissionTime: submissionTime ?? this.submissionTime,
      description: description ?? this.description,
    );
  }
}

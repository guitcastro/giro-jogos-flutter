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

import 'package:giro_jogos/src/services/media_upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giro_jogos/src/models/challenge_submission.dart';

/// A lightweight fake for MediaUploadService used in tests to avoid Firebase initialization.
class FakeMediaUploadService implements MediaUploadService {
  const FakeMediaUploadService();

  @override
  Future<XFile?> pickImageFromGallery() async => null;

  @override
  Future<XFile?> pickVideoFromGallery() async => null;

  @override
  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required XFile imageFile,
    String? description,
  }) async {
    // Return a dummy submission without touching Firebase
    return ChallengeSubmission(
      id: 'fake-image',
      challengeId: challengeId,
      duoId: duoId,
      uploaderUid: 'test-user',
      mediaUrl: 'https://example.com/fake.jpg',
      mediaType: MediaType.image,
      submissionTime: DateTime.now(),
      description: description,
    );
  }

  @override
  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required XFile videoFile,
    String? description,
  }) async {
    // Return a dummy submission without touching Firebase
    return ChallengeSubmission(
      id: 'fake-video',
      challengeId: challengeId,
      duoId: duoId,
      uploaderUid: 'test-user',
      mediaUrl: 'https://example.com/fake.mp4',
      mediaType: MediaType.video,
      submissionTime: DateTime.now(),
      description: description,
    );
  }

  @override
  Stream<List<ChallengeSubmission>> getSubmissionsStream({
    required String challengeId,
    required String duoId,
  }) {
    // Empty stream by default for tests
    return const Stream<List<ChallengeSubmission>>.empty();
  }

  @override
  Future<void> deleteSubmission({
    required String challengeId,
    required String submissionId,
  }) async {
    // No-op in tests
  }
}

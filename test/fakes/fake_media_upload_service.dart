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

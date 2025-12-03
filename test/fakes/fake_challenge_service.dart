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

import 'dart:async';
import 'package:giro_jogos/src/services/challenge_service.dart';
import 'package:giro_jogos/src/models/challenge.dart';
import 'package:giro_jogos/src/models/challenge_submission.dart';
import 'package:giro_jogos/src/models/challenge_score.dart';
import 'package:giro_jogos/src/models/leaderboard_entry.dart';
import 'package:image_picker/image_picker.dart';

/// A fake implementation of [ChallengeService] for widget/unit tests.
///
/// This class avoids any Firebase usage and returns empty streams or simple
/// values as appropriate. Extend as needed in specific tests by composing
/// with stream controllers or by wrapping providers around desired streams.
class FakeChallengeService implements ChallengeService {
  const FakeChallengeService();

  @override
  Stream<int> streamDuoTotalScore(String duoId) => Stream<int>.value(0);

  @override
  Stream<List<Challenge>> getChallengesStream() =>
      const Stream<List<Challenge>>.empty();

  @override
  Future<Challenge?> getChallengeById(int challengeId) async => null;

  @override
  Stream<Challenge> getChallengeByIdStream(int challengeId) =>
      const Stream<Challenge>.empty();

  @override
  Stream<List<ChallengeSubmission>> getAllSubmissionsStream() =>
      const Stream<List<ChallengeSubmission>>.empty();

  @override
  Stream<List<ChallengeSubmission>> getSubmissionsStream({
    required String challengeId,
    required String duoId,
  }) =>
      const Stream<List<ChallengeSubmission>>.empty();

  @override
  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required XFile imageFile,
    String? description,
  }) =>
      throw UnimplementedError();

  @override
  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required XFile videoFile,
    String? description,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deleteSubmission({
    required String challengeId,
    required String submissionId,
  }) async {}

  @override
  Stream<ChallengeScore?> getScoreStream({
    required String duoId,
    required String challengeId,
  }) =>
      const Stream<ChallengeScore?>.empty();

  @override
  Future<ChallengeScore?> getScore({
    required String duoId,
    required String challengeId,
  }) async =>
      null;

  @override
  Future<void> setScore({
    required String duoId,
    required String challengeId,
    required int points,
    required int totalPoints,
    String? comment,
    required String updatedByUid,
  }) async {}

  @override
  Stream<List<LeaderboardEntry>> streamAdminLeaderboard() =>
      const Stream<List<LeaderboardEntry>>.empty();
}

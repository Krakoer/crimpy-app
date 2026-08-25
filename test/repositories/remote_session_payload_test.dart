import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the body a session POST would send, so the payload can be asserted
/// without a server.
class _CapturingApiClient extends ApiClient {
  Map<String, dynamic>? body;

  @override
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> body) async {
    this.body = body;
    return {'id': 's-1'};
  }
}

RepDataModel _rep({String? trainingItemId, HandSide hand = HandSide.right}) =>
    RepDataModel(
      averageWeight: 25,
      duration: 7,
      index: 0,
      isRest: false,
      handSide: hand,
      targetWeight: 30,
      trainingItemId: trainingItemId,
    );

SessionModel _session({String? trainingId, String? programSessionId}) =>
    SessionModel(
      name: 'Session',
      date: DateTime.utc(2026, 8, 21),
      isAssessment: false,
      activity: SessionActivity.hangboard,
      origin: SessionOrigin.played,
      trainingId: trainingId,
      programSessionId: programSessionId,
    );

Future<Map<String, dynamic>> _postedRep({
  String? trainingId,
  String? programSessionId,
  String? trainingItemId,
  HandSide hand = HandSide.right,
}) async {
  final client = _CapturingApiClient();
  await RemoteTrainingRepository(client).saveSession(
    _session(trainingId: trainingId, programSessionId: programSessionId),
    [_rep(trainingItemId: trainingItemId, hand: hand)],
  );
  return (client.body!['rep_datas'] as List).single as Map<String, dynamic>;
}

void main() {
  group('a posted rep', () {
    test('names the item it was played from', () async {
      final rep = await _postedRep(trainingId: 't-1', trainingItemId: 'item-1');

      expect(rep['training_item_id'], 'item-1');
    });

    // The server reads the link against the prescription it froze from
    // training_id, so an item id sent without one would name nothing it knows.
    test('drops the item when the session came from no training', () async {
      final rep = await _postedRep(trainingItemId: 'item-1');

      expect(rep.containsKey('training_item_id'), isFalse);
    });

    // The server resolves the prescription from the program session when one is
    // sent, so the link keys into something even with no training_id alongside.
    test('names the item when only a program session was sent', () async {
      final rep = await _postedRep(
        programSessionId: 'ps-1',
        trainingItemId: 'item-1',
      );

      expect(rep['training_item_id'], 'item-1');
    });

    test('carries no item when the step named none', () async {
      final rep = await _postedRep(trainingId: 't-1');

      expect(rep.containsKey('training_item_id'), isFalse);
    });

    // The hand travels as text because a two handed hang is a state of its own,
    // which the boolean this replaced answered the left hand for.
    test('names the hand it was hung with', () async {
      expect((await _postedRep(hand: HandSide.right))['hand'], 'right');
      expect((await _postedRep(hand: HandSide.left))['hand'], 'left');
      expect((await _postedRep(hand: HandSide.both))['hand'], 'both');
    });
  });
}

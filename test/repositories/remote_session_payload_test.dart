import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

SessionModel _session({
  String? trainingId,
  String? programSessionId,
  bool isAssessment = false,
  List<TrainingItem>? prescriptionItems,
}) => SessionModel(
  name: 'Session',
  date: DateTime.utc(2026, 8, 21),
  isAssessment: isAssessment,
  activity: SessionActivity.hangboard,
  origin: SessionOrigin.played,
  trainingId: trainingId,
  programSessionId: programSessionId,
  prescriptionItems: prescriptionItems,
);

/// The tree a training generated on the device hands over, named by the keys
/// the reports use.
List<TrainingItem> _generatedItems() => const [
  TrainingItem(
    id: '',
    stableKey: 'builtin:mvc:0',
    type: TrainingItemType.repeater,
    position: 0,
    worktimeSeconds: 7,
  ),
];

Future<Map<String, dynamic>> _postedBody({
  bool isAssessment = false,
  List<BleDataPoint>? data,
}) async {
  final client = _CapturingApiClient();
  await RemoteTrainingRepository(
    client,
  ).saveSession(_session(isAssessment: isAssessment), [_rep()], data: data);
  return client.body!;
}

Future<Map<String, dynamic>> _postedItemResults({
  String? trainingId,
  List<TrainingItem>? prescriptionItems,
  required List<String> itemKeys,
}) async {
  final client = _CapturingApiClient();
  await RemoteTrainingRepository(client).saveSession(
    _session(trainingId: trainingId, prescriptionItems: prescriptionItems),
    [_rep()],
    itemResults: [
      for (final key in itemKeys)
        SessionItemResultModel(trainingItemId: key, occurrence: 0, reps: 8),
    ],
  );
  return client.body!;
}

/// The body a session POST sends when the device holds [bodyweightKg], or none
/// when it holds nothing.
Future<Map<String, dynamic>> _postedWithBodyweight(double? bodyweightKg) async {
  SharedPreferences.setMockInitialValues(
    bodyweightKg == null ? {} : {'bodyweight_kg': bodyweightKg},
  );
  final client = _CapturingApiClient();
  await RemoteTrainingRepository(client).saveSession(_session(), [_rep()]);
  return client.body!;
}

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
  _bodyweightTests();

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

  group('the item reports of a posted session', () {
    test('name the items they answer', () async {
      final body = await _postedItemResults(
        trainingId: 't-1',
        itemKeys: ['item-1'],
      );

      expect(
        ((body['item_results'] as List).single
            as Map<String, dynamic>)['training_item_id'],
        'item-1',
      );
    });

    // What #111 added: a run of a training generated on the device hands the
    // server the prescription it played, so a report naming one of its steps
    // keys into something and goes up with it.
    test('go up with the prescription the run carries', () async {
      final body = await _postedItemResults(
        prescriptionItems: _generatedItems(),
        itemKeys: ['builtin:mvc:0'],
      );

      expect(
        ((body['item_results'] as List).single
            as Map<String, dynamic>)['training_item_id'],
        'builtin:mvc:0',
      );
      final prescribed =
          ((body['prescription'] as Map<String, dynamic>)['items'] as List)
                  .single
              as Map<String, dynamic>;
      expect(prescribed['id'], 'builtin:mvc:0');
    });

    // What round 1 of the review caught. A session frozen before a generated
    // step had a name of its own holds a blank id for every one of them, and
    // those sessions are already on devices waiting to be imported. The API
    // refuses such a prescription outright, so sending it would cost the run
    // rather than the reports it could not carry.
    test('hand over no prescription naming an unnamed step', () async {
      final body = await _postedItemResults(
        prescriptionItems: const [
          TrainingItem(id: '', type: TrainingItemType.repeater, position: 0),
        ],
        itemKeys: ['builtin:mvc:0'],
      );

      expect(body.containsKey('prescription'), isFalse);
      expect(body.containsKey('item_results'), isFalse);
    });

    // The server freezes its own copy from a training or a program slot and
    // refuses a second opinion alongside either, so none is sent there.
    test('carry no prescription when the run names a training', () async {
      final body = await _postedItemResults(
        trainingId: 't-1',
        prescriptionItems: _generatedItems(),
        itemKeys: ['item-1'],
      );

      expect(body.containsKey('prescription'), isFalse);
      expect((body['item_results'] as List), hasLength(1));
    });

    // Nothing to key a report into and nothing to hand over: the report has no
    // home and is left off rather than refused by the server.
    test('are left out by a run carrying neither', () async {
      final body = await _postedItemResults(itemKeys: ['builtin:mvc:0']);

      expect(body.containsKey('item_results'), isFalse);
      expect(body.containsKey('prescription'), isFalse);
    });
  });

  group('the force curve of a posted session', () {
    final t0 = DateTime.utc(2026, 8, 21, 10);
    final points = [
      BleDataPoint(0, t0),
      BleDataPoint(31.5, t0.add(const Duration(milliseconds: 125))),
    ];

    test('rides along with an assessment', () async {
      final body = await _postedBody(isAssessment: true, data: points);

      final samples = body['samples'] as Map<String, dynamic>;
      expect(samples['t0'], '2026-08-21T10:00:00.000Z');
      expect(samples['ms'], [0, 125]);
      expect(samples['kg'], [0, 31.5]);
    });

    // The API takes a curve on an assessment only, and refuses the request
    // outright otherwise, so sending one would fail the whole save.
    test('is left off an ordinary session', () async {
      final body = await _postedBody(data: points);

      expect(body.containsKey('samples'), isFalse);
    });

    test('is left off an assessment that recorded nothing', () async {
      final body = await _postedBody(isAssessment: true);

      expect(body.containsKey('samples'), isFalse);
    });
  });
}

void _bodyweightTests() {
  // The server freezes what the run actually resolved its percent_bw loads
  // against, and only the device knows that: it may hold a measurement the
  // server has never been told about, because a run needs no network.
  group('bodyweight', () {
    test('sends the weight the device holds', () async {
      final body = await _postedWithBodyweight(71.4);

      expect(body['bodyweight_kg'], 71.4);
    });

    // Absent rather than zero: nothing has to read 0kg as a real weight.
    test('sends none when the device holds none', () async {
      final body = await _postedWithBodyweight(null);

      expect(body.containsKey('bodyweight_kg'), isFalse);
    });
  });
}

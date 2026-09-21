import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers one session read with whatever payload the test hands it, so the
/// shapes the API can send are exercised without a server.
class _SessionApiClient extends ApiClient {
  _SessionApiClient(this.payload);

  final Map<String, dynamic> payload;

  @override
  Future<Map<String, dynamic>> getSession(String id) async => payload;
}

Map<String, dynamic> _session() => {
  'id': 'session-1',
  'name': 'Repeaters 20mm',
  'notes': '',
  'date': '2026-09-20T17:30:00Z',
  'is_assessment': false,
  'activity': 0,
  'origin': 'played',
  'duration': 1800,
};

Map<String, dynamic> _rep() => {
  'id': 'rep-1',
  'average_weight': 31.0,
  'is_rest': false,
  'hand': 'right',
  'duration': 7,
  'target_weight': 32.0,
  'index': 0,
  'grip_position': 0,
  'target_unmeasured': false,
};

Map<String, dynamic> _itemResult() => {
  'id': 'item-result-1',
  'session_id': 'session-1',
  'training_item_id': 'item-1',
  'occurrence': 0,
  'reps': 11,
  'updated_at': '2026-09-20T17:30:00Z',
};

// Krakoer/crimpy#130. The session detail is drawn from three reads on the
// server, and one that fails leaves its collection out of the answer rather
// than sending it empty. The two states have to stay apart here: absent is a
// collection nobody could read, empty is a session that holds none of it.
//
// The first test is also the regression the release order exists to prevent. An
// absent key must not throw: the app has to tolerate the new shape before the
// backend starts sending it.
void main() {
  test(
    'reads an absent collection as unavailable rather than as empty',
    () async {
      final repository = RemoteTrainingRepository(
        _SessionApiClient({'session': _session()}),
      );

      final session = await repository.getSessionWithData('session-1');

      expect(session, isNotNull);
      expect(session!.repsUnavailable, isTrue);
      expect(session.itemResultsUnavailable, isTrue);
      // The rest of the session is still there, which is the whole point of the
      // server not answering 500 over one collection.
      expect(session.name, 'Repeaters 20mm');
      expect(session.durationInSeconds, 1800);
    },
  );

  test(
    'reads an empty collection as empty rather than as unavailable',
    () async {
      final repository = RemoteTrainingRepository(
        _SessionApiClient({
          'session': _session(),
          'rep_datas': <dynamic>[],
          'item_results': <dynamic>[],
        }),
      );

      final session = await repository.getSessionWithData('session-1');

      expect(session!.repsUnavailable, isFalse);
      expect(session.itemResultsUnavailable, isFalse);
      expect(session.reps, isEmpty);
      expect(session.itemResults, isEmpty);
    },
  );

  test('reads a populated collection as neither', () async {
    final repository = RemoteTrainingRepository(
      _SessionApiClient({
        'session': _session(),
        'rep_datas': [_rep()],
        'item_results': [_itemResult()],
      }),
    );

    final session = await repository.getSessionWithData('session-1');

    expect(session!.repsUnavailable, isFalse);
    expect(session.itemResultsUnavailable, isFalse);
    expect(session.reps, hasLength(1));
    expect(session.itemResults, hasLength(1));
  });

  test('takes one collection missing without losing the other', () async {
    final repository = RemoteTrainingRepository(
      _SessionApiClient({
        'session': _session(),
        'item_results': [_itemResult()],
      }),
    );

    final session = await repository.getSessionWithData('session-1');

    expect(session!.repsUnavailable, isTrue);
    expect(session.itemResultsUnavailable, isFalse);
    expect(session.itemResults, hasLength(1));
  });
}

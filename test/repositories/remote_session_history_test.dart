import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers the session listing with whatever rows the test hands it, and
/// records whether the reps were asked for.
class _ListingApiClient extends ApiClient {
  _ListingApiClient(this.rows);

  final List<Map<String, dynamic>> rows;
  final List<bool> includeRepsAsked = [];

  @override
  Future<List<Map<String, dynamic>>> getSessions({
    bool includeReps = false,
  }) async {
    includeRepsAsked.add(includeReps);
    return rows;
  }
}

Map<String, dynamic> _row(String id, {List<Map<String, dynamic>>? reps}) => {
  'id': id,
  'name': 'Repeaters 20mm',
  'notes': '',
  'date': '2026-09-20T17:30:00Z',
  'is_assessment': false,
  'activity': 0,
  'origin': 'played',
  'duration': 1800,
  'rep_count': reps?.length ?? 0,
  'rep_datas': ?reps,
};

Map<String, dynamic> _rep(int index, double averageWeight) => {
  'id': 'rep-$index',
  'session_id': 'session-1',
  'average_weight': averageWeight,
  'is_rest': false,
  'hand': 'right',
  'duration': 7,
  'target_weight': 0.0,
  'index': index,
  'grip_position': 0,
  'target_unmeasured': false,
};

void main() {
  test('reads the whole history in one listing carrying the reps', () async {
    final api = _ListingApiClient([
      _row('session-1', reps: [_rep(0, 20), _rep(1, 22)]),
      _row('session-2', reps: []),
    ]);

    final history = await RemoteTrainingRepository(
      api,
    ).getSessionHistoryWithReps();

    expect(api.includeRepsAsked, [true]);
    expect(history.map((s) => s.reps?.length), [2, 0]);
    expect(history.first.reps!.last.averageWeight, 22);
  });

  // A server that does not know the include answers the cheap listing, and
  // reading that as sessions with no reps would add the history up to zeros.
  test('refuses a listing that came back without the reps', () async {
    final repository = RemoteTrainingRepository(
      _ListingApiClient([_row('session-1')]),
    );

    expect(repository.getSessionHistoryWithReps(), throwsFormatException);
  });
}

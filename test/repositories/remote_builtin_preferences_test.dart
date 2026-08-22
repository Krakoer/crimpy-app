import 'package:crimpy/repositories/builtin_preferences_repository.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers with the snake_case shape the weights endpoint returns, and records
/// the writes, so the repository can be exercised without a server.
class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.stored = const []});

  final List<Map<String, dynamic>> stored;
  Map<String, dynamic>? created;
  String? updatedId;
  Map<String, dynamic>? updatedBody;

  @override
  Future<List<Map<String, dynamic>>> getBuiltinTrainingWeights() async =>
      stored;

  @override
  Future<Map<String, dynamic>> createBuiltinTrainingWeight(
    Map<String, dynamic> body,
  ) async {
    created = body;
    return body;
  }

  @override
  Future<Map<String, dynamic>> updateBuiltinTrainingWeightApi(
    String id,
    Map<String, dynamic> body,
  ) async {
    updatedId = id;
    updatedBody = body;
    return body;
  }
}

Map<String, dynamic> _weightRow({
  required String id,
  required String builtinTrainingId,
  required double left,
  required double right,
}) => {
  'id': id,
  'user_id': 'u-1',
  'builtin_training_id': builtinTrainingId,
  'custom_weight_left': left,
  'custom_weight_right': right,
  'updated_at': '2026-08-21T10:00:00Z',
};

void main() {
  group('reading custom weights from the API', () {
    test('keys them by the training they override', () async {
      final client = _FakeApiClient(
        stored: [
          _weightRow(
            id: 'w-1',
            builtinTrainingId: 'bt-1',
            left: 12.5,
            right: 14.5,
          ),
        ],
      );

      final weights = await RemoteBuiltinPreferencesRepository(
        client,
      ).getAllCustomWeights();

      expect(weights['bt-1']?.weightLeft, 12.5);
      expect(weights['bt-1']?.weightRight, 14.5);
    });

    test('answers a training with no override with nulls', () async {
      final weights = await RemoteBuiltinPreferencesRepository(
        _FakeApiClient(),
      ).getCustomWeights('bt-1');

      expect(weights.weightLeft, isNull);
      expect(weights.weightRight, isNull);
    });
  });

  group('saving custom weights', () {
    test('updates the existing override rather than adding one', () async {
      final client = _FakeApiClient(
        stored: [
          _weightRow(
            id: 'w-1',
            builtinTrainingId: 'bt-1',
            left: 12.5,
            right: 14.5,
          ),
        ],
      );

      await RemoteBuiltinPreferencesRepository(client).saveCustomWeights(
        builtinTrainingId: 'bt-1',
        weightRight: 20,
        weightLeft: 18,
      );

      expect(client.updatedId, 'w-1');
      expect(client.updatedBody?['custom_weight_left'], 18);
      expect(client.updatedBody?['custom_weight_right'], 20);
      expect(client.created, isNull);
    });

    test('creates one when the training has none yet', () async {
      final client = _FakeApiClient(
        stored: [
          _weightRow(
            id: 'w-1',
            builtinTrainingId: 'bt-other',
            left: 12.5,
            right: 14.5,
          ),
        ],
      );

      await RemoteBuiltinPreferencesRepository(client).saveCustomWeights(
        builtinTrainingId: 'bt-1',
        weightRight: 20,
        weightLeft: 18,
      );

      expect(client.created?['builtin_training_id'], 'bt-1');
      expect(client.created?['custom_weight_left'], 18);
      expect(client.created?['custom_weight_right'], 20);
      expect(client.updatedId, isNull);
    });
  });
}

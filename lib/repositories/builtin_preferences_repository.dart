import 'package:crimpy/database/database.dart';
import 'package:crimpy/services/api_client.dart';
import 'package:uuid/uuid.dart';

abstract class BuiltinPreferencesRepository {
  Future<List<String>> getPinnedBuiltinTrainingIds();
  Future<void> pinBuiltinTraining(String builtinTrainingId);
  Future<void> unpinBuiltinTraining(String builtinTrainingId);
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId);
  Future<({double? weightRight, double? weightLeft})> getCustomWeights(
    String builtinTrainingId,
  );
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  getAllCustomWeights();
  Future<void> saveCustomWeights({
    required String builtinTrainingId,
    required double weightRight,
    required double weightLeft,
  });
}

class LocalBuiltinPreferencesRepository
    implements BuiltinPreferencesRepository {
  final AppDatabase _database;

  LocalBuiltinPreferencesRepository({AppDatabase? database})
    : _database = database ?? gDatabase;

  @override
  Future<List<String>> getPinnedBuiltinTrainingIds() =>
      _database.getPinnedBuiltinTrainingIds();

  @override
  Future<void> pinBuiltinTraining(String builtinTrainingId) =>
      _database.pinBuiltinTraining(builtinTrainingId);

  @override
  Future<void> unpinBuiltinTraining(String builtinTrainingId) =>
      _database.unpinBuiltinTraining(builtinTrainingId);

  @override
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) =>
      _database.isBuiltinTrainingPinned(builtinTrainingId);

  @override
  Future<({double? weightRight, double? weightLeft})> getCustomWeights(
    String builtinTrainingId,
  ) async {
    final w = await _database.getBuiltinTrainingWeights(builtinTrainingId);
    return (weightRight: w?.customWeightRight, weightLeft: w?.customWeightLeft);
  }

  @override
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  getAllCustomWeights() async {
    final rows = await _database.getAllBuiltinTrainingWeights();
    return Map.fromEntries(
      rows.map(
        (w) => MapEntry(w.builtinTrainingId, (
          weightRight: w.customWeightRight,
          weightLeft: w.customWeightLeft,
        )),
      ),
    );
  }

  @override
  Future<void> saveCustomWeights({
    required String builtinTrainingId,
    required double weightRight,
    required double weightLeft,
  }) => _database.saveBuiltinTrainingWeights(
    builtinTrainingId: builtinTrainingId,
    customWeightRight: weightRight,
    customWeightLeft: weightLeft,
  );
}

class RemoteBuiltinPreferencesRepository
    implements BuiltinPreferencesRepository {
  final ApiClient _apiClient;

  RemoteBuiltinPreferencesRepository(this._apiClient);

  @override
  Future<List<String>> getPinnedBuiltinTrainingIds() async {
    final pinned = await _apiClient.getPinnedBuiltinTrainings();
    return pinned.map((p) => p['BuiltinTrainingID'] as String).toList();
  }

  @override
  Future<void> pinBuiltinTraining(String builtinTrainingId) =>
      _apiClient.pinBuiltinTrainingApi(builtinTrainingId);

  @override
  Future<void> unpinBuiltinTraining(String builtinTrainingId) =>
      _apiClient.unpinBuiltinTrainingApi(builtinTrainingId);

  @override
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) async {
    final ids = await getPinnedBuiltinTrainingIds();
    return ids.contains(builtinTrainingId);
  }

  @override
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  getAllCustomWeights() async {
    final weights = await _apiClient.getBuiltinTrainingWeights();
    return Map.fromEntries(
      weights.map(
        (w) => MapEntry(w['BuiltinTraningID'] as String, (
          weightRight: (w['CustomWeightRight'] as num?)?.toDouble(),
          weightLeft: (w['CustomWeightLeft'] as num?)?.toDouble(),
        )),
      ),
    );
  }

  @override
  Future<({double? weightRight, double? weightLeft})> getCustomWeights(
    String builtinTrainingId,
  ) async {
    final all = await getAllCustomWeights();
    return all[builtinTrainingId] ?? (weightRight: null, weightLeft: null);
  }

  @override
  Future<void> saveCustomWeights({
    required String builtinTrainingId,
    required double weightRight,
    required double weightLeft,
  }) async {
    final weights = await _apiClient.getBuiltinTrainingWeights();
    final existing = weights
        .where((w) => w['BuiltinTraningID'] == builtinTrainingId)
        .firstOrNull;
    if (existing != null) {
      await _apiClient.updateBuiltinTrainingWeightApi(
        existing['ID'] as String,
        {'custom_weight_right': weightRight, 'custom_weight_left': weightLeft},
      );
    } else {
      await _apiClient.createBuiltinTrainingWeight({
        'id': const Uuid().v4(),
        'builtin_training_id': builtinTrainingId,
        'custom_weight_right': weightRight,
        'custom_weight_left': weightLeft,
      });
    }
  }
}

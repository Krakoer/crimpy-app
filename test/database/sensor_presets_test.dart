import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/sensor_preset.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> add(String name, {double tare = 1, double coef = 2}) =>
      db.addSensorPreset(NewSensorPreset(name: name, tare: tare, coef: coef));

  test('a saved preset comes back as a domain model', () async {
    await add('Left hand', tare: 3.5, coef: 0.25);

    final presets = await db.getSensorPresets();

    expect(presets, hasLength(1));
    expect(presets.single, isA<SensorPreset>());
    expect(presets.single.name, 'Left hand');
    expect(presets.single.tare, 3.5);
    expect(presets.single.coef, 0.25);
    expect(presets.single.id, isNotEmpty);
  });

  test('storage assigns an increasing position to each new preset', () async {
    await add('first');
    await add('second');
    await add('third');

    final presets = await db.getSensorPresets();

    // Listed newest first, so the positions run downwards.
    expect(presets.map((p) => p.name), ['third', 'second', 'first']);
    expect(presets.map((p) => p.index), [3, 2, 1]);
  });

  test('a deleted preset is gone', () async {
    await add('keep');
    await add('drop');
    final toDelete = (await db.getSensorPresets()).firstWhere(
      (p) => p.name == 'drop',
    );

    await db.deleteSensorPreset(toDelete.id);

    expect((await db.getSensorPresets()).map((p) => p.name), ['keep']);
  });
}

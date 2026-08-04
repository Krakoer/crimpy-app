import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class SensorSettingsList extends ConsumerStatefulWidget {
  /// Displays the saved sensor configurations as a ListView that the user can load and delete.
  const SensorSettingsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SensorSettingsListState();
}

class _SensorSettingsListState extends ConsumerState<SensorSettingsList> {
  @override
  Widget build(BuildContext context) {
    // Get all configs from DB.
    final configs = ref.watch(sensorPresetsProvider);
    return switch (configs) {
      AsyncData(:final value) =>
        value.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text("No preset saved yet."),
              )
            : Column(
                children: value
                    .map(
                      (config) => Dismissible(
                        background: Container(color: CrimpyTheme.errorColor),
                        key: ValueKey<String>(config.id),
                        // Setting card
                        child: CrimpyCard.simple(
                          margin: EdgeInsets.all(16),
                          child: ListTile(
                            title: Text(config.name),
                            // The subtitle prints the config settings (tare & coef)
                            subtitle: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tare: ${config.tare.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CrimpyTheme.gray600,
                                    ),
                                  ),
                                  Text(
                                    "Coef: ${config.coef.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CrimpyTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Trailing "load" button
                            trailing: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(bleConfigProvider.notifier)
                                    .loadPreset(config);
                              },
                              child: Text("Load"),
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(sensorPresetsProvider.notifier)
                              .deletePreset(config.id);
                        },
                      ),
                    )
                    .toList(),
              ),
      AsyncError() => const Text('Oops, something unexpected happened'),
      _ => const CircularProgressIndicator(),
    };
  }
}

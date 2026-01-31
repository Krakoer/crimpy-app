import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/calibration/start_calibration_dialog.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/create_sensor_config_dialog.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/sensor_settings_list.dart';
import 'package:drift/drift.dart' as dr;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/utils/dummy_data_generator.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  /// Screen that allow the user to manage the app settings, including:
  /// - The sensor calibration settings
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tareController = TextEditingController();
  final _calibrationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(bleConfigProvider);
    _tareController.text = settings.tare.toStringAsFixed(2);
    _calibrationController.text = settings.calibration.toStringAsFixed(2);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SentryFeedbackWidget.show(context);
        },
        tooltip: 'Report a bug',
        child: const Icon(FontAwesomeIcons.bullhorn),
      ),
      body: Column(
        children: [
          // Form for manually editting tare and calibration values.
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tare row.
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tareController,
                          decoration: const InputDecoration(
                            labelText: 'Tare value',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null) {
                              return 'Please enter a valid tare value';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            ref.watch(connectionStateProvider) ==
                                    BleConnectionState.connected
                                ? () {
                                  ref.read(bleConfigProvider.notifier).tare();
                                }
                                : null,
                        child: Text("Tare"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Calibration coef row.
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _calibrationController,
                          decoration: const InputDecoration(
                            labelText: 'Calibration value',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null) {
                              return 'Please enter a valid calibration value';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            ref.watch(connectionStateProvider) ==
                                    BleConnectionState.connected
                                ? () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => StartCalibrationDialog(),
                                  );
                                }
                                : null,
                        child: Text("Calibrate"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Save settings and create preset buttons.
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8),
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Save settings'),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: ElevatedButton(
                    onPressed: _showCreatePresetPopup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('+ Create preset'),
                  ),
                ),
              ),
            ],
          ),
          // List of saved presets.
          SensorSettingsList(),
          // Debug section - only visible in debug mode
          if (kDebugMode) ...[
            const Divider(thickness: 2, height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Debug Tools',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate dummy data for testing and screenshots',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _generateDummyData,
                    icon: const Icon(Icons.data_array),
                    label: const Text('Generate Dummy Data'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Manually load the settings in the form.
  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      ref
          .read(bleConfigProvider.notifier)
          .setCalibration(double.parse(_calibrationController.text));
      ref
          .read(bleConfigProvider.notifier)
          .setTare(double.parse(_tareController.text));
    }
  }

  /// Displays the dialog to create a new settings preset.
  void _showCreatePresetPopup() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder:
            (ctx) => CreatePresetDialog(
              onSave: (String presetName) {
                ref
                    .read(sensorConfigsProvider.notifier)
                    .addSensorConfig(
                      SensorConfigsCompanion(
                        coef: dr.Value(
                          double.parse(_calibrationController.text),
                        ),
                        tare: dr.Value(double.parse(_tareController.text)),
                        name: dr.Value(presetName),
                      ),
                    );
              },
            ),
      );
    }
  }

  /// Generate dummy data for testing and screenshots (debug mode only).
  void _generateDummyData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Generate Dummy Data'),
            content: const Text(
              'This will populate your database with sample sessions, trainings, and assessments. '
              'This is useful for testing and taking screenshots.\n\n'
              'Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Generate'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final trainingRepository = TrainingRepository();
      final generator = DummyDataGenerator(trainingRepository);
      await generator.generateAllDummyData();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dummy data generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating dummy data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Clear all data from the database (debug mode only).
  void _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will DELETE all sessions and custom trainings from your database. '
              'This action cannot be undone!\n\n'
              'Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final trainingRepository = TrainingRepository();
      final generator = DummyDataGenerator(trainingRepository);
      await generator.clearAllData();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

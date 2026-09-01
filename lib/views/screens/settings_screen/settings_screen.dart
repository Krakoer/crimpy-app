import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/services/notification_service.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/calibration/start_calibration_dialog.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/create_sensor_config_dialog.dart';
import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:crimpy/views/screens/settings_screen/run_screen_style_picker_screen.dart';
import 'package:crimpy/viewmodels/app_info_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/availability/week_availability_screen.dart';
import 'package:crimpy/views/screens/settings_screen/notification_settings_screen.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/debug_modal.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/sensor_settings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/models/sensor_preset.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  /// Screen that allow the user to manage the app settings, including:
  /// - The sensor calibration settings
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  final _tareController = TextEditingController();
  final _calibrationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = ref.watch(bleConfigProvider);
    _tareController.text = settings.tare.toStringAsFixed(2);
    _calibrationController.text = settings.calibration.toStringAsFixed(2);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                                        ref
                                            .read(bleConfigProvider.notifier)
                                            .tare();
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
                                          builder: (ctx) =>
                                              StartCalibrationDialog(),
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
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Run screen design'),
                    subtitle: const Text(
                      'How the gauge and timer are laid out',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (ref.watch(runScreenStyleProvider).value ??
                                  RunScreenStyle.fallback)
                              .displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CrimpyTheme.primaryOrange,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const RunScreenStylePickerScreen(),
                      ),
                    ),
                  ),
                  // Only for a coached athlete: with no coach there is nobody
                  // for the week to be sent to.
                  if (ref.watch(coachEnrollmentProvider).asData?.value != null)
                    ListTile(
                      leading: const Icon(Icons.event_available),
                      title: const Text('Your week'),
                      subtitle: const Text(
                        'Tell your coach when you can train',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const WeekAvailabilityScreen(),
                        ),
                      ),
                    ),
                  // Reminders only exist for coach-assigned programs, and only
                  // on the platforms that can deliver a scheduled notification.
                  if (supportsTrainingReminders &&
                      ref.watch(activeProgramProvider).asData?.value != null)
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('Training reminders'),
                      subtitle: const Text(
                        'Get reminded of the trainings your coach scheduled',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                  // List of saved presets.
                  SensorSettingsList(),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: TextButton(
              onPressed: () => showDebugModal(context),
              child: Text(
                ref
                        .watch(appInfoProvider)
                        .whenOrNull(
                          data: (info) => 'Crimpy v${info.version}',
                        ) ??
                    'Crimpy',
              ),
            ),
          ),
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
        builder: (ctx) => CreatePresetDialog(
          onSave: (String presetName) {
            ref
                .read(sensorPresetsProvider.notifier)
                .addPreset(
                  NewSensorPreset(
                    name: presetName,
                    coef: double.parse(_calibrationController.text),
                    tare: double.parse(_tareController.text),
                  ),
                );
          },
        ),
      );
    }
  }
}

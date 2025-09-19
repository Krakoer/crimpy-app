import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/calibration/run_calibration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartCalibrationDialog extends ConsumerStatefulWidget {
  /// Dialog to explain the user the calibration protocol, and ask him to enter the calibration weight.
  /// This dialog will then show the `RunCalibrationDialog`.
  const StartCalibrationDialog({super.key});

  @override
  ConsumerState<StartCalibrationDialog> createState() =>
      _CalibrationDialogState();
}

class _CalibrationDialogState extends ConsumerState<StartCalibrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              double targetWeight = double.parse(_targetController.value.text);
              Navigator.of(context).pop();
              ref.read(bleConfigProvider.notifier).startCalibration();
              showDialog(
                context: context,
                // Prevent the run dialog to be dismissed.
                barrierDismissible: false,
                builder:
                    (ctx) => RunCalibrationDialog(targetWeight: targetWeight),
              );
            }
          },
          child: Text("Start calibration"),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Explainations for the calibration protocol.
            Text(
              "1. Make sure the sensor is tared before starting calibration\n2. Enter the known calibration weight in the input below.\n3. Hang the weight on the sensor, wait for it to be stable and click on \"Start calibration\".",
              style: TextStyle(height: 2),
            ),
            SizedBox(height: 12),
            // Form to ask the user to input the calibration weight.
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Target weight (kg)',
                        border: OutlineInputBorder(),
                        hintText: "e.g. 12.9",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the calibration weight';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                      controller: _targetController,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("kg"),
                ],
              ),
            ),
          ],
        ),
      ),
      title: Text("Calibrate your sensor"),
    );
  }
}

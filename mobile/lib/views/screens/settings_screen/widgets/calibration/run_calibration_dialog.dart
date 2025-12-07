import 'dart:async';

import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunCalibrationDialog extends ConsumerStatefulWidget {
  final double targetWeight;

  /// Dialog to run a calibration session given a target weight.
  /// This dialog will simply show a countdown of 5 seconds, and stop the calibration at the end.
  const RunCalibrationDialog({required this.targetWeight, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CalibrationRunDialogState();
}

class _CalibrationRunDialogState extends ConsumerState<RunCalibrationDialog> {
  late Timer _timer;
  int secondCount = 0;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondCount += 1;
      });
      if (secondCount == 5) {
        ref
            .read(bleConfigProvider.notifier)
            .stopCalibration(widget.targetWeight);
        Navigator.of(context).pop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Calibrating..."),
      content: Padding(
        padding: EdgeInsets.all(20),
        child: Text((5 - secondCount).toString()),
      ),
    );
  }
}

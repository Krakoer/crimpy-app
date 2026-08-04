import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TareDialog extends ConsumerStatefulWidget {
  const TareDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TareDialogState();
}

class _TareDialogState extends ConsumerState<TareDialog> {
  @override
  Widget build(BuildContext context) {
    final lastValue = ref.watch(bleLastValueProvider);
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;
    final bleString =
        "${lastValue == null ? "--" : lastValue.toStringAsFixed(2)} kg";
    return AlertDialog(
      title: Text("Tare sensor"),
      actions: [
        TextButton(
          onPressed: connected
              ? ref.read(bleConfigProvider.notifier).tare
              : null,
          child: Text("Tare"),
        ),
        TextButton(
          onPressed: connected
              ? () {
                  Navigator.of(context).pop();
                }
              : null,
          child: Text("Exit"),
        ),
      ],
      content: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 20),
        child: Text(
          bleString,
          style: TextStyle(fontSize: 26),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

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
    final bleValue = ref.watch(bleDataStreamProvider);
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;
    final bleString =
        "${switch (bleValue) {
          AsyncData(:final value) => value.lastOrNull == null ? "--" : value.lastOrNull!.value.toStringAsFixed(2),
          _ => "--",
        }} kg";
    return AlertDialog(
      title: Text("Tare sensor"),
      actions: [
        TextButton(
          onPressed:
              connected ? ref.read(bleConfigProvider.notifier).tare : null,
          child: Text("Tare"),
        ),
        TextButton(
          onPressed:
              connected
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

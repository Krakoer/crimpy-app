import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tares the sensor, asking first when the reading is loaded or stale, since
/// that reading would become the new zero and offset every reading after it.
Future<void> tareUnlessLoaded(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(bleConfigProvider.notifier);
  final check = controller.checkTare();
  if (check == null) return;
  if (!check.needsConfirmation) {
    await controller.tare();
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (_) => LoadedTareDialog(check: check),
  );
}

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
        // Left enabled when the sensor drops, or the dialog, which the
        // barrier cannot dismiss, would have no way out.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Done"),
        ),
        FilledButton(
          onPressed: connected ? () => tareUnlessLoaded(context, ref) : null,
          child: Text("Tare"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Take all load off the sensor, then tare it.",
            style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textSecondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: CrimpyTheme.spaceLgPlus,
            ),
            child: Text(
              bleString,
              style: CrimpyTheme.tabular(CrimpyTheme.headline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks before taring a sensor that still carries a load, or that stopped
/// sending readings, showing the load that would become the new zero. Closes
/// by itself when the sensor disconnects.
class LoadedTareDialog extends ConsumerStatefulWidget {
  const LoadedTareDialog({super.key, required this.check});

  final TareCheck check;

  @override
  ConsumerState<LoadedTareDialog> createState() => _LoadedTareDialogState();
}

class _LoadedTareDialogState extends ConsumerState<LoadedTareDialog> {
  late TareCheck _check = widget.check;
  bool _readingChanged = false;
  bool _closed = false;

  /// Pops the prompt once, and only while it is the route on top: dismissed
  /// from its barrier or by Back, it is still mounted through its exit, and a
  /// disconnection then must not pop the tare dialog under it.
  void _close() {
    if (_closed || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  Future<void> _confirm() async {
    final outcome = await ref
        .read(bleConfigProvider.notifier)
        .tareConfirmed(_check);
    if (!mounted) return;
    switch (outcome) {
      case TareChanged(:final check):
        setState(() {
          _check = check;
          _readingChanged = true;
        });
      case TareDone() || TareCancelled():
        _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionStateProvider, (_, state) {
      if (state != BleConnectionState.connected) _close();
    });
    final load = "${_check.loadKg.toStringAsFixed(1)} kg";
    final stale = _check.concern == TareConcern.stale;
    // A sensor tared under load reads below zero once the load is off, and
    // taring it again is the fix rather than the mistake.
    final belowZero = _check.loadKg < 0;
    return AlertDialog(
      title: Text(
        stale
            ? "No recent reading"
            : belowZero
            ? "The sensor reads below zero"
            : "The sensor is loaded",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_readingChanged)
            Padding(
              padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceSm),
              child: Text(
                "The reading changed since you were asked.",
                style: CrimpyTheme.titleSmall,
              ),
            ),
          Text(
            stale
                ? "The sensor has not sent a reading for a few seconds. "
                      "Taring now makes its last one, $load, the new zero."
                : belowZero
                ? "It reads $load, so it was probably tared with a load on "
                      "it. Tare it again with nothing hanging on it."
                : "It reads $load. Taring now makes that load the new zero, "
                      "and every reading after it is off by as much. Take "
                      "the load off the sensor first.",
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: _close, child: const Text("Cancel")),
        // Below zero, taring is the fix the prompt recommends, not a risk.
        FilledButton(
          style: belowZero && !stale ? null : CrimpyTheme.destructiveButton,
          onPressed: _confirm,
          child: Text(belowZero && !stale ? "Tare now" : "Tare anyway"),
        ),
      ],
    );
  }
}

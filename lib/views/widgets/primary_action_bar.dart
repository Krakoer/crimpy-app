import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bar pinned under a screen that holds its one primary action, full
/// width, so the action stays in reach however long the content above it is.
class PrimaryActionBar extends StatelessWidget {
  final Widget child;

  const PrimaryActionBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        CrimpyTheme.spaceLg,
        CrimpyTheme.spaceMd,
        CrimpyTheme.spaceLg,
        CrimpyTheme.spaceLg,
      ),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(top: BorderSide(color: CrimpyTheme.outline, width: 2)),
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

/// Starts a training, in the primary style. Says it will connect the sensor
/// first when the training can be measured and none is connected, since that
/// is what tapping it then does.
class StartTrainingButton extends ConsumerWidget {
  final Training training;
  final VoidCallback onPressed;

  const StartTrainingButton({
    required this.training,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow),
      label: Text(
        training.canUseSensor && !connected
            ? 'CONNECT AND START'
            : 'START TRAINING',
      ),
      // The theme fills it with the action colour; only the height is this
      // bar's own.
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceLg),
      ),
    );
  }
}

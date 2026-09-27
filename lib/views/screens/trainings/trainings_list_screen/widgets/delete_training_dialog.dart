import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class DeleteTrainingDialog extends ConsumerWidget {
  final String trainingId;

  const DeleteTrainingDialog({required this.trainingId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Delete Training?'),
      content: const Text(
        'This action cannot be undone. All data associated with this training will be permanently removed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep it'),
        ),
        FilledButton(
          onPressed: () {
            // The delete drops the library, and the full list is built from
            // it, so it re-evaluates the builtins on its own.
            ref.read(trainingsProvider.notifier).deleteTraining(trainingId);
            Navigator.of(context).pop();
          },
          style: CrimpyTheme.destructiveButton,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

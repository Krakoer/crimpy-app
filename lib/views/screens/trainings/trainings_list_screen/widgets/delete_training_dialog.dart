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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Training?'),
      content: const Text(
        'This action cannot be undone. All data associated with this training will be permanently removed.',
        style: TextStyle(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: CrimpyTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // The delete drops the library, and the full list is built from
            // it, so it re-evaluates the builtins on its own.
            ref.read(trainingsProvider.notifier).deleteTraining(trainingId);
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: CrimpyTheme.statusError.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Delete',
            style: TextStyle(
              color: CrimpyTheme.textOn(CrimpyTheme.statusError),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

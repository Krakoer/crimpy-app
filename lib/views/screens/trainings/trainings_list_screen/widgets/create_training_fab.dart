import 'package:crimpy/views/screens/trainings/training_creation_screen.dart';
import 'package:flutter/material.dart';

class CreateTrainingFab extends StatelessWidget {
  const CreateTrainingFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showModeSheet(context),
      child: const Icon(Icons.add),
    );
  }

  void _showModeSheet(BuildContext context) {
    showModalBottomSheet<TrainingCreationMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Simple Repeater'),
              subtitle: const Text('Configure a repeater training'),
              onTap: () => Navigator.pop(ctx, TrainingCreationMode.repeater),
            ),
            ListTile(
              leading: const Icon(Icons.pan_tool),
              title: const Text('Manual Hangboard'),
              subtitle: const Text(
                'Build a training from reps, cycles and groups',
              ),
              onTap: () => Navigator.pop(ctx, TrainingCreationMode.manual),
            ),
          ],
        ),
      ),
    ).then((mode) {
      if (mode != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UnifiedTrainingCreationScreen(mode: mode),
          ),
        );
      }
    });
  }
}

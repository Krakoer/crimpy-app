import 'package:crimpy/views/screens/trainings/training_creation_screen.dart';
import 'package:flutter/material.dart';

class CreateTrainingFab extends StatelessWidget {
  const CreateTrainingFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const UnifiedTrainingCreationScreen(),
        ),
      ),
      child: const Icon(Icons.add),
    );
  }
}

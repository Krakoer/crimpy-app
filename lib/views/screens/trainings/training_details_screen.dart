import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final Training template;
  const TrainingDetailScreen(this.template, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = template.goal?.trim() ?? '';
    final comment = template.comment?.trim() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (goal.isNotEmpty) ...[
              const SectionLabel('Goal'),
              const SizedBox(height: 8),
              SectionTextBlock(goal),
              const SizedBox(height: 16),
            ],
            if (comment.isNotEmpty) ...[
              const SectionLabel('Instructions'),
              const SizedBox(height: 8),
              SectionTextBlock(comment),
              const SizedBox(height: 16),
            ],
            if (template.items.isNotEmpty) ...[
              const SectionLabel('Exercises'),
              const SizedBox(height: 8),
              ...buildTrainingItemTiles(template.items),
            ],
          ],
        ),
      ),
      floatingActionButton: IconButton(
        onPressed:
            ref.watch(connectionStateProvider) != BleConnectionState.connected
            ? null
            : () {
                ref.read(bleSessionProvider.notifier).reset();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => PlayTrainingScreen(template),
                  ),
                );
              },
        icon: Icon(Icons.play_arrow),
      ),
    );
  }
}

import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final Training template;
  const TrainingDetailScreen(this.template, {super.key});

  /// Starts the run, asking for the body weight first when the training is
  /// loaded in percent of it and none is known yet.
  Future<void> _startRun(BuildContext context, WidgetRef ref) async {
    final bodyweight = await resolveBodyweight(context, ref, template);
    if (!context.mounted) return;
    ref.read(bleSessionProvider.notifier).reset();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) =>
            PlayTrainingScreen(template, bodyweightKg: bodyweight),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = template.goal?.trim() ?? '';
    final comment = template.comment?.trim() ?? '';
    final bodyweightKg = ref.watch(bodyweightProvider).value;

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
              ...buildTrainingItemTiles(
                template.items,
                bodyweightKg: bodyweightKg,
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: IconButton(
        onPressed:
            ref.watch(connectionStateProvider) != BleConnectionState.connected
            ? null
            : () => _startRun(context, ref),
        icon: Icon(Icons.play_arrow),
      ),
    );
  }
}

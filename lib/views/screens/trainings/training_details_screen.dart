import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final Training template;
  const TrainingDetailScreen(this.template, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: SafeArea(
        child: ListView.builder(
          itemCount: template.items.length,
          itemBuilder: (ctx, i) {
            final item = template.items[i];
            return ListTile(
              title: Text(item.type.apiValue),
              subtitle: Text(switch (item.type.apiValue) {
                'repeater' =>
                  '${item.cycles ?? 1}x${item.reps ?? 1} '
                      '${item.worktimeSeconds ?? 7}s/${item.restSeconds ?? 3}s',
                'hangboard_rep' =>
                  '${item.worktimeSeconds ?? 7}s / rest ${item.restSeconds ?? 3}s',
                'free' => item.freeText ?? '',
                _ => '',
              }),
            );
          },
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

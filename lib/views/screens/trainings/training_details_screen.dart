import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final TrainingWithReps template;
  const TrainingDetailScreen(this.template, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(template.name)),
      body: SafeArea(
        child: ListView.builder(
          itemCount: template.reps.length,
          itemBuilder:
              (ctx, i) => RepListItem(
                key: ValueKey(i),
                rep: template.reps[i],
                index: i,
              ),
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

class RepListItem extends StatelessWidget {
  final RepModel rep;
  final int index;

  const RepListItem({required Key key, required this.rep, required this.index})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    String repText = '${rep.durationInSeconds}s';
    if (!rep.isRest) {
      repText +=
          ' | ${rep.handSide.isRightHand ? 'Right' : 'Left'} hand | ${rep.targetWeight.toStringAsFixed(1)}kg';
    }

    return CrimpyCards.training(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              rep.isRest ? CrimpyTheme.successColor : CrimpyTheme.errorColor,
          child: Text('${index + 1}'),
        ),
        title: Text(rep.isRest ? "Rest" : "Pull"),
        subtitle: Text(repText),
      ),
    );
  }
}

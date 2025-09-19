import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/models/training_model.dart';

class TrainingHistoryList extends StatelessWidget {
  final List<SessionModel> trainings;
  const TrainingHistoryList({super.key, required this.trainings});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (ctx, i) => TrainingHistoryItem(training: trainings[i]),
        itemCount: trainings.length,
      ),
    );
  }
}

class TrainingHistoryItem extends StatelessWidget {
  final SessionModel training;
  const TrainingHistoryItem({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(FontAwesomeIcons.dumbbell),
      title: Text(training.name),
      subtitle: Text(training.date.toIso8601String()),
    );
  }
}

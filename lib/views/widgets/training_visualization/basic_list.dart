import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Basic list view for non-repeater trainings
class BasicRepList extends StatelessWidget {
  final List<RepModel> reps;

  const BasicRepList({super.key, required this.reps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reps.length,
      itemBuilder: (ctx, i) => _buildBasicRepItem(reps[i], i),
    );
  }

  Widget _buildBasicRepItem(RepModel rep, int index) {
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
          backgroundColor: rep.isRest
              ? CrimpyTheme.successColor
              : CrimpyTheme.errorColor,
          child: Text('${index + 1}'),
        ),
        title: Text(rep.isRest ? "Rest" : "Pull"),
        subtitle: Text(repText),
      ),
    );
  }
}

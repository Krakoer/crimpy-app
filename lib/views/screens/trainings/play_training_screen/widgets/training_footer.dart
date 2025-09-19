import 'package:crimpy/utils/format.dart';
import 'package:flutter/material.dart';

class TrainingFooter extends StatelessWidget {
  final int timeLeftMilliseconds;
  final int currentRepIndex;
  final int numberReps;
  const TrainingFooter({
    super.key,
    required this.currentRepIndex,
    required this.numberReps,
    required this.timeLeftMilliseconds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text("Reps:"),
              Text(
                "$currentRepIndex / $numberReps",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              Text("Time Left"),
              Text(
                formatMillisHHMMSS(timeLeftMilliseconds),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

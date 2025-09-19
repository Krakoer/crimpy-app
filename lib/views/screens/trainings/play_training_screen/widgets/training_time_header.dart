import 'package:flutter/material.dart';
import 'package:crimpy/utils/format.dart';

class TrainingTimeHeader extends StatelessWidget {
  final int elapsedMilliseconds;
  final int timeLeftMilliseconds;

  /// Shows the given elapsed and remaining time.
  const TrainingTimeHeader({
    super.key,
    required this.elapsedMilliseconds,
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
              Text("Elapsed Time"),
              Text(
                formatMillisHHMMSS(elapsedMilliseconds),
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

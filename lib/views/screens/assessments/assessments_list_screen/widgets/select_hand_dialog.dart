import 'dart:math' as math;

import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectHandDialog extends StatelessWidget {
  /// Dialog to ask the user to select which hand to assess.
  /// Returns `true` if right hand is selected, `false` for the left hand, and `null` if canceled.
  const SelectHandDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select the hand to test"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: Row(
              children: [
                Transform(
                  transform: Matrix4.rotationY(math.pi),
                  alignment: Alignment.center,
                  child: Icon(FontAwesomeIcons.hand),
                ),
                SizedBox(width: 5),
                Text('Left'),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop(HandSide.left);
            },
          ),
          ElevatedButton(
            child: Row(
              children: [
                Text('Right'),
                SizedBox(width: 5),
                Icon(FontAwesomeIcons.hand),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop(HandSide.right);
            },
          ),
        ],
      ),
    );
  }
}

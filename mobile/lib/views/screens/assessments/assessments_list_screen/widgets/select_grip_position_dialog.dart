import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';

class SelectGripPositionDialog extends StatelessWidget {
  /// Dialog to ask the user to select which grip position to use for the assessment.
  /// Returns the selected [GripPosition] or `null` if canceled.
  const SelectGripPositionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Grip Position"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            GripPosition.values.map((position) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(position.displayName),
                    onPressed: () {
                      Navigator.of(context).pop(position);
                    },
                  ),
                ),
              );
            }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

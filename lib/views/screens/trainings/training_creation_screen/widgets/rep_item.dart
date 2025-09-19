import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class RepListItem extends StatelessWidget {
  final RepModel rep;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RepListItem({
    required Key key,
    required this.rep,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String repText = '${rep.durationInSeconds}s';
    if (!rep.isRest) {
      repText +=
          ' | ${rep.handSide.isRightHand ? 'Right' : 'Left'} hand | ${rep.targetWeight}kg';
    }

    return CrimpyCards.training(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              rep.isRest ? CrimpyTheme.successColor : CrimpyTheme.errorColor,
          child: Text('${index + 1}'),
        ),
        title: Text(rep.isRest ? "Rest" : "Pull"),
        subtitle: Text(repText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit Rep',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete Rep',
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Offers back a run that finished and was never saved, because the app died
/// on its review. Pops true to review it, false to discard it.
/// Krakoer/crimpy#146.
class UnsavedRunDialog extends StatelessWidget {
  final FinishedRunDraft draft;

  const UnsavedRunDialog({required this.draft, super.key});

  @override
  Widget build(BuildContext context) {
    final started = draft.startedAt;
    final when =
        '${DateFormat.MMMd().format(started)} at '
        '${DateFormat.Hm().format(started)}';
    return AlertDialog(
      title: const Text('Your last run was not saved'),
      content: Text(
        '${draft.title}, started on $when, finished before the app closed. '
        'Review it to keep it in your history, or discard it.',
        style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Review run'),
        ),
      ],
    );
  }
}

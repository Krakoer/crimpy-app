import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// The whole of a coach note, for a step whose prose the run screen had to cut
/// short. A note sits on a step the athlete ends themselves, so opening this
/// costs them nothing: they are stood in front of the phone rather than hanging
/// off the wall, and the run carries on behind it.
Future<void> showNoteDialog(BuildContext context, String text) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Note'),
        content: SingleChildScrollView(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              height: 1.45,
              color: CrimpyTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// What a collection the server could not read looks like on a session.
///
/// The detail is drawn from three reads, and one that fails leaves its
/// collection out of the answer rather than sending it empty. Said out loud
/// rather than drawn as nothing: a missing card reads as a session that
/// recorded none of it, which is the wrong thing to tell an athlete about a read
/// that failed. Krakoer/crimpy#130.
class SessionDataUnavailableCard extends StatelessWidget {
  /// What could not be read, named the way the card that would have held it
  /// names it, so the sentence reads as being about this session.
  final String what;

  const SessionDataUnavailableCard({super.key, required this.what});

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off, size: 20, color: CrimpyTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$what could not be loaded, so nothing here says what it held.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

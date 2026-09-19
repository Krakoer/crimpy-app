import 'package:crimpy/models/session_rpe.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// What the athlete answers for a session, as one value. The two fields are one
/// answer, so they travel together rather than as an int and a bool a caller
/// could set into disagreement.
class SessionRpeAnswer {
  final int? rpe;
  final bool failed;

  const SessionRpeAnswer({this.rpe, this.failed = false});

  static const SessionRpeAnswer none = SessionRpeAnswer();

  /// What a stored session already answered, which is what the edit screens
  /// seed the picker with.
  factory SessionRpeAnswer.of({int? rpe, bool rpeFailed = false}) => rpeFailed
      ? const SessionRpeAnswer(failed: true)
      : SessionRpeAnswer(rpe: rpe);

  bool get isAnswered => failed || rpe != null;

  bool matches(SessionRpeOption option) =>
      option.isFailure ? failed : (!failed && rpe == option.value);
}

/// Asks how much a session cost, on the session RPE scale, with every written
/// anchor on screen.
///
/// The anchors are shown rather than hidden behind the selected value: a bare
/// 1 to 10 slider is exactly what makes an RPE unreadable, and the words are
/// what tell this scale from the set RPE scale, which measures reps left in
/// reserve. Tapping the option already chosen takes the answer back, so an
/// athlete who picked the wrong one is not stuck with it.
class SessionRpePicker extends StatelessWidget {
  final SessionRpeAnswer answer;
  final ValueChanged<SessionRpeAnswer> onChanged;

  /// Set on the screens where the answer is being given after the fact, so the
  /// prompt reads as a correction rather than as a question about a run that
  /// just finished.
  final String? subtitle;

  const SessionRpePicker({
    super.key,
    required this.answer,
    required this.onChanged,
    this.subtitle,
  });

  void _select(SessionRpeOption option) {
    if (answer.matches(option)) {
      onChanged(SessionRpeAnswer.none);
      return;
    }
    onChanged(
      option.isFailure
          ? const SessionRpeAnswer(failed: true)
          : SessionRpeAnswer(rpe: option.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  color: CrimpyTheme.primaryOrange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Session RPE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle ?? 'How much recovery did this session cost you?',
              style: const TextStyle(
                fontSize: 13,
                color: CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            for (final option in sessionRpeOptions)
              _SessionRpeOptionTile(
                option: option,
                selected: answer.matches(option),
                onTap: () => _select(option),
              ),
            const SizedBox(height: 8),
            Text(
              answer.isAnswered
                  ? 'Tap the answer again to clear it. You can also change it later.'
                  : 'Optional. You can add it later from the session.',
              style: const TextStyle(
                fontSize: 12,
                color: CrimpyTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRpeOptionTile extends StatelessWidget {
  final SessionRpeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SessionRpeOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A failure is not a harder session, so it is coloured as the error it is
    // rather than as the top of the scale.
    final accent = option.isFailure
        ? CrimpyTheme.statusError
        : CrimpyTheme.primaryOrange;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CrimpyTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? accent : CrimpyTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(CrimpyTheme.radiusMedium),
                  border: Border.all(
                    color: selected ? accent : CrimpyTheme.borderDark,
                  ),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: option.isFailure ? 11 : 14,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? CrimpyTheme.primaryWhite
                        : CrimpyTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.anchor,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected
                        ? CrimpyTheme.textPrimary
                        : CrimpyTheme.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

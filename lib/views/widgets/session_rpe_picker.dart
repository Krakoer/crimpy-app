import 'package:crimpy/models/session_rpe.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  color: CrimpyTheme.control,
                ),
                const SizedBox(width: CrimpyTheme.spaceSm),
                const Text('Session RPE', style: CrimpyTheme.title),
              ],
            ),
            const SizedBox(height: CrimpyTheme.spaceXs),
            Text(
              subtitle ?? 'How much recovery did this session cost you?',
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: CrimpyTheme.spaceMd),
            for (final option in sessionRpeOptions)
              _SessionRpeOptionTile(
                option: option,
                selected: answer.matches(option),
                onTap: () => _select(option),
              ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            Text(
              answer.isAnswered
                  ? 'Tap the answer again to clear it. You can also change it later.'
                  : 'Optional. You can add it later from the session.',
              style: CrimpyTheme.bodySmall.copyWith(
                color: CrimpyTheme.textMutedSmall,
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
        : CrimpyTheme.control;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: CrimpyTheme.corners,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceSm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? accent : CrimpyTheme.bgSecondary,
                  borderRadius: CrimpyTheme.corners,
                  border: Border.all(
                    color: selected ? accent : CrimpyTheme.outlineSubtle,
                  ),
                ),
                child: Text(
                  option.label,
                  style:
                      (option.isFailure
                              ? CrimpyTheme.labelSmall
                              : CrimpyTheme.titleSmall)
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? CrimpyTheme.textOnFill
                                : CrimpyTheme.textSecondary,
                          ),
                ),
              ),
              const SizedBox(width: CrimpyTheme.spaceMd),
              Expanded(
                child: Text(
                  option.anchor,
                  style: CrimpyTheme.body.copyWith(
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

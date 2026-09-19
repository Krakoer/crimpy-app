/// The session RPE scale, how much recovery a session cost. It is the scale the
/// coach's week sheet prints, and the written anchor is what makes a value
/// readable: "8" on its own is ambiguous between this scale and the set RPE
/// scale, which measures reps left in reserve and belongs to a set rather than
/// to a session. So the picker shows the anchors, never a bare slider.
///
/// The scale starts at 5 because that is where its anchors start, and it
/// mirrors the sessions_rpe_check constraint the API enforces.
class SessionRpeOption {
  /// The value stored on the session, or null for the scale's ECHEC, which is
  /// kept as a flag of its own rather than as a number outside the range.
  final int? value;

  /// The short form a picked option is shown by.
  final String label;

  /// The written anchor, which is the whole of what makes the value usable.
  final String anchor;

  const SessionRpeOption({
    required this.value,
    required this.label,
    required this.anchor,
  });

  bool get isFailure => value == null;
}

const int minSessionRpe = 5;
const int maxSessionRpe = 10;

/// Every answer the athlete may give, in the order the sheet prints them.
const List<SessionRpeOption> sessionRpeOptions = [
  SessionRpeOption(value: 5, label: '5', anchor: 'Active recovery, warm up'),
  SessionRpeOption(value: 6, label: '6', anchor: 'Easy but productive'),
  SessionRpeOption(
    value: 7,
    label: '7',
    anchor: 'Needs less than a day of rest before repeating it',
  ),
  SessionRpeOption(
    value: 8,
    label: '8',
    anchor: 'Needs one full rest day before repeating it',
  ),
  SessionRpeOption(value: 9, label: '9', anchor: 'Needs two full rest days'),
  SessionRpeOption(
    value: 10,
    label: '10',
    anchor: 'Needs three or more full rest days',
  ),
  SessionRpeOption(
    value: null,
    label: 'ECHEC',
    anchor: 'Could not be carried through',
  ),
];

/// What the athlete answered for a session, as one value. The two fields are
/// one answer, so they travel together rather than as an int and a bool a
/// caller could set into disagreement, and the assert is what makes the
/// disagreement unrepresentable rather than merely unproduced.
class SessionRpeAnswer {
  final int? rpe;
  final bool failed;

  const SessionRpeAnswer({this.rpe, this.failed = false})
    : assert(
        !failed || rpe == null,
        'ECHEC is a value of the scale, so it cannot sit beside a number',
      );

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

/// The option a session's stored answer reads as, or null when the athlete has
/// reported nothing. A value the app does not know, from a server that widened
/// the scale, reads as nothing rather than as a wrong anchor.
SessionRpeOption? sessionRpeOptionOf({int? rpe, bool rpeFailed = false}) {
  if (rpeFailed) return sessionRpeOptions.last;
  if (rpe == null) return null;
  for (final option in sessionRpeOptions) {
    if (option.value == rpe) return option;
  }
  return null;
}

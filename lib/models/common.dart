enum HandSide { right, left, both }

extension HandSideExtension on HandSide {
  /// Whether the single hand worked is the right one. Only ask this where the
  /// two single hands are the only cases, assessments in particular: a two
  /// handed hang answers false, so a caller that can meet [HandSide.both] reads
  /// it as the left hand.
  bool get isRightHand => switch (this) {
    HandSide.right => true,
    HandSide.left || HandSide.both => false,
  };

  /// The shouted form the play screen prints while a rep runs.
  String get displayName => switch (this) {
    HandSide.left => "LEFT HAND",
    HandSide.right => "RIGHT HAND",
    HandSide.both => "BOTH HANDS",
  };

  /// The form the history rows name a recorded rep with.
  String get label => switch (this) {
    HandSide.left => "Left Hand",
    HandSide.right => "Right Hand",
    HandSide.both => "Both Hands",
  };

  /// How the hand travels to the API and the local database. The three states
  /// are stored as text rather than as an index so the vocabulary is the same
  /// one the backend and the portal read.
  String get apiValue => name;
}

/// Resolves a hand from its stored or server-supplied name. A name this build
/// does not know reads as [HandSide.both], the state that names no single hand,
/// so a rep written by a newer one is never claimed for the wrong side.
///
/// Takes a name rather than a nullable one on purpose: a rep carrying no hand
/// at all is a contract the caller is not speaking, not a hand to guess at, and
/// the caller is the one that can tell the reader so.
HandSide handSideFromApi(String value) => switch (value) {
  'right' => HandSide.right,
  'left' => HandSide.left,
  _ => HandSide.both,
};

enum GripPosition {
  halfCrimp,
  threeFinger,
  fullCrimp,
  openHand,
  // Add more grip positions as needed
}

extension GripPositionExtension on GripPosition {
  String get displayName => switch (this) {
    GripPosition.halfCrimp => "Half Crimp",
    GripPosition.threeFinger => "3-Finger Drag",
    GripPosition.fullCrimp => "Full Crimp",
    GripPosition.openHand => "Open Hand",
  };

  String get shortName => switch (this) {
    GripPosition.halfCrimp => "HC",
    GripPosition.threeFinger => "3FD",
    GripPosition.fullCrimp => "FC",
    GripPosition.openHand => "OH",
  };
}

/// What the athlete did. A label only: it drives colors, filters and the week
/// histogram, and never decides what the app allows on a session. The order is
/// the stored one, on the device and on the server alike, so new values go last.
enum SessionActivity {
  hangboard,
  climbing,
  stretching,
  workout, // Physical training (abs, pullups, etc)
  other, // Anything else worth logging, a run in particular
}

extension SessionActivityExtension on SessionActivity {
  String get displayName => switch (this) {
    SessionActivity.hangboard => "Hangboard",
    SessionActivity.climbing => "Climbing",
    SessionActivity.stretching => "Stretching",
    SessionActivity.workout => "Workout",
    SessionActivity.other => "Other",
  };
}

/// How a session came to exist. Set by the code path that produced it, never
/// picked by a user, so it stays a fact about the session rather than a label.
enum SessionOrigin {
  /// Run step by step in the app. It owns its reps and its timings, so only its
  /// notes may be edited afterwards.
  played,

  /// Entered by hand after the fact, so every field stays editable.
  logged,
}

extension SessionOriginExtension on SessionOrigin {
  String get apiValue => name;

  /// Whether the session was produced by a run rather than typed in. Everything
  /// the app locks down on a session hangs off this, never off the activity.
  bool get isPlayed => this == SessionOrigin.played;
}

/// Resolves an origin from its stored or server-supplied name. An unknown value
/// reads as logged, the permissive case, so a session written by a newer build
/// stays editable instead of freezing.
SessionOrigin sessionOriginFromApi(String? value) =>
    value == SessionOrigin.played.name
    ? SessionOrigin.played
    : SessionOrigin.logged;

/// Edge depth the app prescribes when nothing else says otherwise. The builtin
/// assessments and trainings are all measured on it, so their reps are pinned
/// to it rather than left without an edge.
const int defaultEdgeSizeMm = 20;

/// Resolves an enum from a stored or server-supplied index. Indexes outside the
/// known range resolve to [fallback], so a value added on the backend before the
/// app supports it degrades gracefully instead of throwing a RangeError.
T enumFromIndex<T>(List<T> values, num? index, T fallback) {
  final i = index?.toInt();
  return (i == null || i < 0 || i >= values.length) ? fallback : values[i];
}

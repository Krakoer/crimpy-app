/// How long a hold lasted when it ends on the last sample the sensor sent
/// rather than on the moment the run noticed it was gone.
///
/// [elapsed] is the hold's clock when the run gave up at [now]. The time from
/// [lastSampleAt] to [now] was counted without a reading behind it, so it comes
/// off. Without a sample the whole of [elapsed] stands, and a sample older than
/// the hold itself leaves nothing held.
Duration heldUntilLastSample({
  required Duration elapsed,
  required DateTime now,
  required DateTime? lastSampleAt,
}) {
  if (lastSampleAt == null) return elapsed;
  final unread = now.difference(lastSampleAt);
  if (unread.isNegative) return elapsed;
  final held = elapsed - unread;
  return held.isNegative ? Duration.zero : held;
}

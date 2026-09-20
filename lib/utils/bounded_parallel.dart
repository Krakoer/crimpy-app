/// How many tasks a repository fan-out keeps outstanding at once.
///
/// A library of fifty trainings or a season of programs is dozens of requests,
/// and firing them all together is a burst the athlete's connection has to
/// absorb in one go.
const int defaultFanOutConcurrency = 6;

/// Runs [tasks] with at most [concurrency] of them outstanding, keeping the
/// results in the order the tasks were given.
///
/// A task that throws takes the whole call down with it, the way an unbounded
/// `Future.wait` would: the call waits for the tasks already running before it
/// rethrows the first error raised, and it is the worker that hit the failure
/// which stops taking work, not the others. A caller that wants one failure to
/// leave the rest of the fan-out alone catches inside its own task and answers
/// with a placeholder.
Future<List<T>> inParallel<T>(
  Iterable<Future<T> Function()> tasks, {
  int concurrency = defaultFanOutConcurrency,
}) async {
  assert(concurrency > 0, 'inParallel needs at least one worker');

  final pending = tasks.toList();
  final results = List<T?>.filled(pending.length, null);
  var next = 0;

  Future<void> worker() async {
    while (true) {
      final index = next++;
      if (index >= pending.length) return;
      results[index] = await pending[index]();
    }
  }

  final workers = concurrency < pending.length ? concurrency : pending.length;
  await Future.wait([for (var i = 0; i < workers; i++) worker()]);
  return results.cast<T>();
}

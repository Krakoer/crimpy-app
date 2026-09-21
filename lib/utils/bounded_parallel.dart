/// How many tasks a repository fan-out keeps outstanding at once.
///
/// Every assessment a coach has prescribed is dozens of requests, and firing
/// them all together is a burst the athlete's connection has to absorb in one
/// go. The program walk has no list endpoint to read itself off and pays that
/// every time. The training library has one, and comes through here only when
/// the server answering it is old enough to ignore the parameter.
const int defaultFanOutConcurrency = 6;

/// Runs [tasks] with at most [concurrency] of them outstanding, keeping the
/// results in the order the tasks were given.
///
/// A task that throws takes the whole call down with it, the way an unbounded
/// `Future.wait` would, but it does not stop the fan-out: only the worker that
/// hit the failure stops taking work, so every task left in the queue is still
/// run before the first error raised is rethrown. On a long list that makes the
/// failure surface a good deal later than it would have without the bound. A
/// caller that wants one failure to leave the rest of the fan-out alone catches
/// inside its own task and answers with a placeholder, the way the prescribed
/// assessment fetch does.
Future<List<T>> inParallel<T>(
  Iterable<Future<T> Function()> tasks, {
  int concurrency = defaultFanOutConcurrency,
}) async {
  if (concurrency < 1) {
    throw ArgumentError.value(
      concurrency,
      'concurrency',
      'inParallel needs at least one worker',
    );
  }

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

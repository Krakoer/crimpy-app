import 'dart:async';

import 'package:crimpy/logger.dart';
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// How long a pull waits before it gives up on saying anything.
///
/// The providers retry on their own, four attempts with a backoff, and each one
/// may sit on the API's connect timeout: a pull the athlete made can otherwise
/// spin for about two minutes. It stops asking for their attention well before
/// that. Nothing is cancelled, so an answer that arrives late still lands on the
/// screen; only the spinner stops promising it is coming.
const Duration _refreshPatience = Duration(seconds: 15);

/// Pull down to fetch again what the screen reads from the store.
///
/// The athlete's coach writes their week, answers their notes and edits their
/// trainings while the app is open, and a provider that already resolved has no
/// reason to ask again. This is how the athlete says to ask now.
///
/// Wraps [RefreshIndicator] for three reasons worth having in one place. The
/// spinner is the app's own colour rather than the framework's blue. A failure
/// is answered for rather than dropped: `RefreshIndicator` discards the future
/// it is handed, so an `onRefresh` that throws becomes an uncaught async error
/// and nothing at all to the athlete, who is left looking at a list that did
/// not change and was never told why. And a pull cannot outlast
/// [_refreshPatience].
///
/// Catching it here takes it off the path that would otherwise have reported
/// it, since the zone `main` guards is what sends anything to Sentry and
/// [AppLoggerHelper] only writes to the console and the in-memory log the debug
/// screen shows. So this reports it instead of only swallowing it.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// What to fetch again. Held to until it completes, so it should await the
  /// data rather than only asking for it: an indicator that disappears before
  /// the new list arrives reads as a refresh that did nothing.
  ///
  /// Invalidate the providers that do the fetching, not only the ones the
  /// screen reads. Riverpod invalidates a provider alone and never what it was
  /// derived from, so refreshing a filtered list recomputes it against the
  /// answer already cached and comes back with what was already on screen.
  final Future<void> Function() onRefresh;

  final Widget child;

  Future<void> _refresh(ScaffoldMessengerState? messenger) async {
    try {
      await onRefresh().timeout(_refreshPatience);
    } on TimeoutException {
      _say(messenger, 'Still trying. This is taking longer than usual.');
    } catch (error, stackTrace) {
      AppLoggerHelper.error('Could not refresh', error);
      // Reported, since catching it here takes it off the path that would have
      // reported it. Except when the request never reached the server: an
      // athlete pulling in a gym basement is not a defect, and one event per
      // pull would bury the failures that are. The stack is the failure's
      // rather than this catch's, which is the only one that says where it
      // came from.
      if (error is! ApiException || !error.isOffline) {
        unawaited(Sentry.captureException(error, stackTrace: stackTrace));
      }
      // Says what happened and not why: a refresh fails on a dropped
      // connection and on a server that answered 500 alike, and naming the
      // first would be a diagnosis this has no way of making. The cause goes
      // where it can be read rather than being guessed at on screen.
      _say(messenger, 'Could not refresh. Please try again.');
    }
  }

  /// Held from before the await rather than read after it, so nothing looks up
  /// an ancestor through a context whose screen may have been left since.
  void _say(ScaffoldMessengerState? messenger, String message) {
    if (messenger == null || !messenger.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => _refresh(ScaffoldMessenger.maybeOf(context)),
    color: CrimpyTheme.primaryOrange,
    child: child,
  );
}

/// Makes a child scrollable over the whole viewport, so a screen too short to
/// scroll can still be pulled.
///
/// [RefreshIndicator] listens to a scroll notification and a [ListView] that
/// fits on screen sends none. Screens whose content is a column rather than a
/// list wrap it in this instead.
class RefreshableColumn extends StatelessWidget {
  const RefreshableColumn({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // The padding sits outside the constrained child, so its height has to
      // come off the minimum or the column is always taller than the viewport
      // by exactly the padding and drags up onto blank space.
      final inset =
          padding?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;
      final available = constraints.maxHeight - inset.vertical;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: available > 0 ? available : 0),
          child: child,
        ),
      );
    },
  );
}

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Pull down to fetch again what the screen reads from the store.
///
/// The athlete's coach writes their week, answers their notes and edits their
/// trainings while the app is open, and a provider that already resolved has no
/// reason to ask again. This is how the athlete says to ask now.
///
/// Wraps [RefreshIndicator] for two reasons worth having in one place: the
/// spinner is the app's own colour rather than the framework's blue, and the
/// child is forced to scroll even when it is shorter than the screen, since a
/// list that cannot move is a list that cannot be pulled. An empty history is
/// exactly when refreshing it matters most.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// What to fetch again. Pull refreshes hold the spinner until this completes,
  /// so it should await the data rather than only asking for it: an indicator
  /// that disappears before the new list arrives reads as a refresh that did
  /// nothing.
  final Future<void> Function() onRefresh;

  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
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
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}

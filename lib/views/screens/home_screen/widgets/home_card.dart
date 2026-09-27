import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final Widget child;
  final Widget? topLeft;
  final String title;
  final VoidCallback? onTap;

  /// Whether the card stands raised. Left out, it is raised when it has an
  /// [onTap], as CrimpyCard decides.
  final bool? raised;

  const HomeCard({
    required this.child,
    required this.title,
    this.onTap,
    this.topLeft,
    this.raised,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      onTap: onTap,
      raised: raised,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: CrimpyTheme.title.copyWith(
                    color: CrimpyTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              topLeft ?? Container(),
            ],
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.all(8.0), child: child),
        ],
      ),
    );
  }
}

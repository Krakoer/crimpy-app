import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks the layout every training run is drawn with.
class RunScreenStylePickerScreen extends ConsumerWidget {
  const RunScreenStylePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(runScreenStyleProvider).value ?? RunScreenStyle.fallback;

    return Scaffold(
      appBar: AppBar(title: const Text('Run screen design')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Applies to every training run. Pick the one you read fastest '
            'with the phone on the ground.',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              height: 1.6,
              color: CrimpyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (final style in RunScreenStyle.values) ...[
            _StyleCard(
              style: style,
              isSelected: style == selected,
              onTap: () => ref.read(runScreenStyleProvider.notifier).set(style),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final RunScreenStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = isSelected
        ? CrimpyTheme.primaryOrange
        : CrimpyTheme.borderDefault;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? CrimpyTheme.primaryOrange.withValues(alpha: 0.06)
              : CrimpyTheme.primaryWhite,
          border: Border.all(color: ink, width: 2),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(3, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 84,
              child: _StyleThumbnail(style: style),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.displayName,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? CrimpyTheme.textOn(CrimpyTheme.primaryOrange)
                          : CrimpyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.description,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      height: 1.5,
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected
                    ? CrimpyTheme.fillOn(CrimpyTheme.primaryOrange)
                    : CrimpyTheme.primaryWhite,
                border: Border.all(color: ink, width: isSelected ? 0 : 1),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: CrimpyTheme.primaryWhite,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Schematic of a design: the shapes the run screen is made of, at a size
/// where only the arrangement reads.
class _StyleThumbnail extends StatelessWidget {
  final RunScreenStyle style;

  const _StyleThumbnail({required this.style});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: CrimpyTheme.primaryWhite,
      border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
    ),
    child: switch (style) {
      RunScreenStyle.ringAndTank => Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CrimpyTheme.primaryOrange, width: 3),
          ),
        ),
      ),
      RunScreenStyle.fullTank => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 5),
            child: Text(
              '7',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w900,
                color: CrimpyTheme.primaryBlack,
              ),
            ),
          ),
          const Spacer(),
          const Expanded(
            flex: 3,
            child: ColoredBox(color: CrimpyTheme.gray600),
          ),
        ],
      ),
    },
  );
}

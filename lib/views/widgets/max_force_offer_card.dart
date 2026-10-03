import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/max_force_offer.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Offers the pulls that beat the Max Force on file as new ones, one line per
/// hand and grip. Nothing is ticked to begin with and nothing is saved from
/// here: the screen showing it saves the ticked offers with the rest, so an
/// athlete who ignores the card keeps the max they had.
class MaxForceOfferCard extends StatelessWidget {
  final List<MaxForceOffer> offers;
  final Set<MaxForceOffer> accepted;
  final void Function(MaxForceOffer offer, bool accept) onChanged;

  /// Says where the pulls come from, since the card reads the same after a
  /// training and after a test.
  final String intro;

  /// Says how a ticked pull is recorded.
  final String note;

  const MaxForceOfferCard({
    super.key,
    required this.offers,
    required this.accepted,
    required this.onChanged,
    this.intro = 'A pull in this training beat your Max Force on file.',
    this.note =
        'Optional. A ticked pull is saved as your Max Force, marked as '
        'coming from a training rather than a test.',
  });

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
                const Icon(Icons.trending_up, color: CrimpyTheme.control),
                const SizedBox(width: CrimpyTheme.spaceSm),
                const Text('New Max Force', style: CrimpyTheme.title),
              ],
            ),
            const SizedBox(height: CrimpyTheme.spaceXs),
            Text(
              intro,
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            for (final offer in offers)
              CheckboxListTile(
                value: accepted.contains(offer),
                onChanged: (value) => onChanged(offer, value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${offer.hand.label}, ${offer.gripPosition.displayName}',
                  style: CrimpyTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${formatAssessmentValue(offer.peakKg, AssessmentUnit.kilograms)}, '
                  'up from ${formatAssessmentValue(offer.onFileKg, AssessmentUnit.kilograms)}',
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            Text(
              note,
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

/// What a review says when some of the Max Forces the athlete ticked could
/// not be stored: which hand and grip did not land, and that the rest did, so
/// the athlete does not redo a pull that is already on file. [alongside] names
/// what was saved with them, which did land.
String unsavedMaxForceMessage(
  List<AssessmentResultModel> failed, {
  required int saved,
  String alongside = 'Training',
}) {
  final names = failed
      .map(
        (result) =>
            '${result.hand?.label.toLowerCase() ?? 'max'}'
            '${result.gripPosition == null ? '' : ', ${result.gripPosition!.displayName}'}',
      )
      .join(' and ');
  final kept = saved == 0
      ? ''
      : ' The other ${saved == 1 ? 'one was' : '$saved were'} saved.';
  final subject = failed.length == 1
      ? 'the new Max Force ($names) was'
      : 'the new Max Forces ($names) were';
  return '$alongside saved, but $subject not.$kept';
}

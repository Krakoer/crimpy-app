import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/models/max_force_offer.dart';
import 'package:crimpy/views/widgets/max_force_offer_card.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CriticalForceResultScreen extends ConsumerStatefulWidget {
  final double? previousCriticalForce;
  final CriticalForceResults results;
  final AssessmentResultModel saveAssessment;
  final SessionModel saveSession;
  final List<RepDataModel> saveReps;
  final List<BleDataPoint> data;

  /// The readings on the analysis' time footing, for the trace.
  final List<CriticalForceSample> samples;

  /// Whole seconds the run stood paused once the first pull had started.
  final int pausedSeconds;

  /// The hand, grip and edge the test was pulled with, which its share of max
  /// and the Max Force its hardest pull may beat are read on.
  final HandSide hand;
  final GripPosition gripPosition;
  final int? edgeSizeMm;

  const CriticalForceResultScreen({
    this.previousCriticalForce,
    required this.results,
    required this.data,
    required this.samples,
    this.pausedSeconds = 0,
    required this.hand,
    required this.gripPosition,
    required this.edgeSizeMm,
    required this.saveAssessment,
    required this.saveSession,
    required this.saveReps,
    super.key,
  });

  @override
  ConsumerState<CriticalForceResultScreen> createState() =>
      _CriticalForceResultScreenState();
}

class _CriticalForceResultScreenState
    extends ConsumerState<CriticalForceResultScreen> {
  /// The new Max Force the athlete ticked. None to begin with: the hardest
  /// pull is offered, never saved without a tap.
  final Set<MaxForceOffer> _acceptedMaxForces = {};

  CriticalForceResults get results => widget.results;

  /// Stores the test, then the maxes kept from it on its session, apart from
  /// it: the test is saved whatever happens to them, so a failure must not
  /// leave the athlete on a screen that would store it twice. [maxForces] is
  /// read before the first await, since the screen may be gone after it.
  Future<void> _save(
    BuildContext context,
    Assessments maxForces,
    List<AssessmentResultModel> keptMaxForces,
  ) async {
    final String sessionId;
    try {
      sessionId = await ref
          .read(
            assessmentsProvider(BuiltinAssessmentIds.criticalForce).notifier,
          )
          .saveAssessment(
            widget.saveAssessment,
            widget.saveSession,
            widget.saveReps,
            data: widget.data,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving assessment: $e')));
      }
      return;
    }
    if (keptMaxForces.isNotEmpty) {
      final failed = await maxForces.addResultsToSession(
        keptMaxForces,
        sessionId,
      );
      if (failed.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              unsavedMaxForceMessage(
                failed,
                saved: keptMaxForces.length - failed.length,
                alongside: 'Critical Force',
              ),
            ),
          ),
        );
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lateOff = results.lateOffCount;
    final maxForceHistory = ref
        .watch(assessmentsProvider(BuiltinAssessmentIds.maxForce))
        .value;
    // The Max Force on file for this hand and grip, which the Critical Force
    // is read as a share of. A test's own hardest pull is not one: it is
    // offered below instead.
    final maxOnFile = maxForceHistory == null
        ? null
        : MaxForceOffer.latestOnFile(
            maxForceHistory,
            widget.hand,
            widget.gripPosition,
          );
    final shareOfMax = maxOnFile == null || maxOnFile <= 0
        ? null
        : (results.criticalForce / maxOnFile * 100).round();
    final maxForceOffers = maxForceHistory == null
        ? const <MaxForceOffer>[]
        : MaxForceOffer.fromPulls([
            MeasuredPull(
              hand: widget.hand,
              gripPosition: widget.gripPosition,
              edgeSizeMm: widget.edgeSizeMm,
              peakKg: results.peakKg,
            ),
          ], maxForceHistory);
    return Scaffold(
      appBar: AppBar(title: Text("Critical Force assessment results")),
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: CrimpyTheme.spaceLgPlus),
            Text(
              "Great job!",
              textAlign: TextAlign.center,
              style: CrimpyTheme.headline.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
            SizedBox(height: CrimpyTheme.spaceLg),
            ResultCard(
              prevValue: widget.previousCriticalForce,
              newValue: results.criticalForce,
            ),
            SizedBox(height: CrimpyTheme.spaceLgPlus),
            Text(
              "Critical force:",
              textAlign: TextAlign.center,
              style: CrimpyTheme.headline.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "${results.criticalForce.toStringAsFixed(2)} kg",
              textAlign: TextAlign.center,
              style: CrimpyTheme.numerals(
                48,
              ).copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            if (shareOfMax != null)
              Text(
                "$shareOfMax % of your max",
                textAlign: TextAlign.center,
                style: CrimpyTheme.title.copyWith(
                  color: CrimpyTheme.textPrimary,
                ),
              ),
            Text(
              "W' ${results.wPrime.round()} kg.s",
              textAlign: TextAlign.center,
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            Text(
              _countedPullsLabel(results),
              textAlign: TextAlign.center,
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            if (widget.pausedSeconds > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceLg,
                  vertical: CrimpyTheme.spaceXs,
                ),
                child: Text(
                  "The test was paused for ${widget.pausedSeconds} s. Extra rest lets the forearm recover, so this result may read high.",
                  textAlign: TextAlign.center,
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
            if (lateOff > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceLg,
                  vertical: CrimpyTheme.spaceXs,
                ),
                child: Text(
                  lateOff == 1
                      ? "1 pull was held on after the bell. Force past the bell does not count."
                      : "$lateOff pulls were held on after the bell. Force past the bell does not count.",
                  textAlign: TextAlign.center,
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
            SizedBox(
              height: 280,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                series: <CartesianSeries>[
                  FastLineSeries<CriticalForceSample, double>(
                    width: 2,
                    dataSource: widget.samples,
                    xValueMapper: (CriticalForceSample sample, _) => sample.t,
                    yValueMapper: (CriticalForceSample sample, _) => sample.kg,
                  ),
                  // Each pull's mean, in the middle of its window.
                  ScatterSeries<CriticalForcePull, double>(
                    dataSource: [
                      for (final pull in results.pulls)
                        if (pull.meanKg != null) pull,
                    ],
                    xValueMapper: (pull, _) => (pull.start + pull.end) / 2,
                    yValueMapper: (pull, _) => pull.meanKg,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  // Dashed line at the Critical Force, across the test.
                  LineSeries<(double, double), double>(
                    dataSource: [
                      (results.pulls.first.start, results.criticalForce),
                      (results.pulls.last.end, results.criticalForce),
                    ],
                    xValueMapper: (data, _) => data.$1,
                    yValueMapper: (data, _) => data.$2,
                    dashArray: <double>[5, 5],
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
                primaryYAxis: NumericAxis(
                  axisLine: AxisLine(color: Colors.transparent),
                  majorGridLines: MajorGridLines(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                primaryXAxis: NumericAxis(
                  axisLine: AxisLine(color: Colors.transparent),
                  majorTickLines: MajorTickLines(size: 0),
                  majorGridLines: MajorGridLines(width: 0),
                  autoScrollingMode: AutoScrollingMode.end,
                  decimalPlaces: 0,
                ),
              ),
            ),
            if (maxForceOffers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceLg,
                ),
                child: MaxForceOfferCard(
                  offers: maxForceOffers,
                  accepted: _acceptedMaxForces,
                  onChanged: (offer, accept) => setState(
                    () => accept
                        ? _acceptedMaxForces.add(offer)
                        : _acceptedMaxForces.remove(offer),
                  ),
                  intro:
                      'The hardest pull of this test beat your Max Force on file.',
                  note:
                      'Optional. A ticked pull is saved as your Max Force, marked '
                      'as kept from this test rather than measured by a Max '
                      'Force test.',
                ),
              ),
            // Room for the save and discard buttons floating over the bottom,
            // so they do not sit on the chart.
            const SizedBox(
              height: kMinInteractiveDimension + CrimpyTheme.spaceLg,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () async {
              // Read off what is still on screen, so an offer ticked and then
              // taken back by a refreshed history is not saved.
              final keptMaxForces = [
                for (final offer in maxForceOffers)
                  if (_acceptedMaxForces.contains(offer))
                    offer.toResult(AssessmentOrigin.training),
              ];
              // Taken before the first await: the athlete can leave while the
              // test is saved, and the kept max is still written after it.
              final maxForces = ref.read(
                assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier,
              );
              final release = keptMaxForces.isEmpty
                  ? null
                  : maxForces.holdOpen();
              try {
                await _save(context, maxForces, keptMaxForces);
              } finally {
                release?.call();
              }
            },
            child: Text("Save new result"),
          ),
          TextButton(
            child: Text("Discard"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Which pulls the Critical Force is the mean of, saying so when holes in the
/// readings left some of them out.
String _countedPullsLabel(CriticalForceResults results) {
  final span = "pulls ${results.firstCountedPull}-${results.lastCountedPull}";
  final spanLength = results.lastCountedPull - results.firstCountedPull + 1;
  return results.averagedPullCount == spanLength
      ? "Mean of $span"
      : "Mean of ${results.averagedPullCount} of $span";
}

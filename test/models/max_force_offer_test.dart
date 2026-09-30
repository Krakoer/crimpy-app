import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/max_force_offer.dart';
import 'package:flutter_test/flutter_test.dart';

const _edge = BuiltinAssessmentIds.maxForceEdgeSizeMm;

MeasuredPull _pull(
  double peakKg, {
  HandSide hand = HandSide.right,
  GripPosition grip = GripPosition.halfCrimp,
  int? edge = _edge,
}) => MeasuredPull(
  hand: hand,
  gripPosition: grip,
  edgeSizeMm: edge,
  peakKg: peakKg,
);

AssessmentModel _maxForce(
  DateTime date, {
  double? right,
  double? left,
  GripPosition grip = GripPosition.halfCrimp,
}) => AssessmentModel(
  id: 'a-${date.millisecondsSinceEpoch}',
  date: date,
  definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
  rightValue: right,
  leftValue: left,
  gripPosition: grip,
);

void main() {
  final march = DateTime(2026, 3, 2);
  final june = DateTime(2026, 6, 2);

  test('offers a single hand pull that beats the max on file', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(38), _pull(42.3)],
      [_maxForce(march, right: 40, left: 39)],
    );

    expect(offers, [
      const MaxForceOffer(
        hand: HandSide.right,
        gripPosition: GripPosition.halfCrimp,
        peakKg: 42.3,
        onFileKg: 40,
      ),
    ]);
  });

  test('compares against the latest result, not the best one', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(41)],
      [_maxForce(march, right: 45), _maxForce(june, right: 40)],
    );

    expect(offers.single.onFileKg, 40);
  });

  test('a two handed pull never updates a one hand max', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(80, hand: HandSide.both)],
      [_maxForce(march, right: 40, left: 40)],
    );

    expect(offers, isEmpty);
  });

  test('a pull on another edge is a different measurement', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(50, edge: 30), _pull(50, edge: null)],
      [_maxForce(march, right: 40)],
    );

    expect(offers, isEmpty);
  });

  test('a pull is only held against the max of its own grip', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(35, grip: GripPosition.openHand)],
      [
        _maxForce(march, right: 40),
        _maxForce(march, right: 30, grip: GripPosition.openHand),
      ],
    );

    expect(offers.single.gripPosition, GripPosition.openHand);
    expect(offers.single.onFileKg, 30);
  });

  test('a pull is only held against the max of its own hand', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(41, hand: HandSide.left)],
      [_maxForce(march, right: 35), _maxForce(june, left: 42)],
    );

    expect(offers, isEmpty);
  });

  test('offers nothing when there is no max on file to beat', () {
    final offers = MaxForceOffer.fromPulls([_pull(50)], const []);

    expect(offers, isEmpty);
  });

  test('offers nothing for a pull that only ties the max once rounded', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(40.04)],
      [_maxForce(march, right: 40)],
    );

    expect(offers, isEmpty);
  });

  test('offers the hardest pull per hand, left first', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(41), _pull(43), _pull(42, hand: HandSide.left)],
      [_maxForce(march, right: 40, left: 40)],
    );

    expect(offers.map((o) => (o.hand, o.peakKg)), [
      (HandSide.left, 42.0),
      (HandSide.right, 43.0),
    ]);
  });

  test('saves the peak on its own hand, as a result from a training', () {
    const offer = MaxForceOffer(
      hand: HandSide.left,
      gripPosition: GripPosition.threeFinger,
      peakKg: 42,
      onFileKg: 40,
    );

    final result = offer.toResult(AssessmentOrigin.training);

    expect(result.assessmentId, BuiltinAssessmentIds.maxForce);
    expect(result.leftValue, 42);
    expect(result.rightValue, isNull);
    expect(result.gripPosition, GripPosition.threeFinger);
    expect(result.origin, AssessmentOrigin.training);
  });

  // Percent loads resolve against the max of their own grip, so a pull that
  // beats its grip's max can only make that grip's loads harder, whatever a
  // newer result on another grip says. See Krakoer/crimpy#182.
  test('offers a pull that beats its own grip, below a newer other grip', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(33, grip: GripPosition.openHand)],
      [
        _maxForce(march, right: 30, grip: GripPosition.openHand),
        _maxForce(june, right: 45),
      ],
    );

    expect(offers.single.gripPosition, GripPosition.openHand);
    expect(offers.single.onFileKg, 30);
  });

  test('offers a pull that also beats the value loads resolve against', () {
    final offers = MaxForceOffer.fromPulls(
      [_pull(46, grip: GripPosition.openHand)],
      [
        _maxForce(march, right: 30, grip: GripPosition.openHand),
        _maxForce(june, right: 45),
      ],
    );

    expect(offers.single.gripPosition, GripPosition.openHand);
    // Up from its own grip's max, which is what it is a new max of.
    expect(offers.single.onFileKg, 30);
  });
}

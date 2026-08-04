// From https://github.com/StuartLittlefair/PyTindeq/blob/main/laptop/src/analysis.py
import 'dart:math';
import 'package:crimpy/models/assessment_model.dart';

List<int> _getRaisingEdgesIndex(List<double> forces, {double threshold = 7}) {
  List<int> raisingEdgesIndex = [];
  for (int i = 1; i < forces.length; i++) {
    if (forces[i] > threshold && forces[i - 1] <= threshold) {
      raisingEdgesIndex.add(i);
    }
  }
  return raisingEdgesIndex;
}

List<int> _getFallingEdgesIndex(List<double> forces, {double threshold = 7}) {
  List<int> fallingEdgesIndex = [];
  for (int i = 1; i < forces.length; i++) {
    if (forces[i] <= threshold && forces[i - 1] > threshold) {
      fallingEdgesIndex.add(i);
    }
  }
  return fallingEdgesIndex;
}

List<double> _sigmaClippedStats(List<double> data) {
  if (data.isEmpty) {
    return [0.0, 0.0, 0.0];
  }

  List<bool> mask = List.filled(data.length, true);
  for (int i = 0; i < 5; i++) {
    List<double> maskedData = data
        .asMap()
        .entries
        .where((entry) => mask[entry.key])
        .map((entry) => entry.value)
        .toList();

    if (maskedData.isEmpty) {
      return [0.0, 0.0, 0.0];
    }

    double mean =
        maskedData.fold(0.0, (prev, element) => prev + element) /
        maskedData.length;

    double std = _standardDeviation(maskedData);
    if (std == 0.0) {
      // All values are the same, no need to continue clipping
      break;
    }

    mask = List.generate(
      data.length,
      (index) => (data[index] - mean).abs() < 4 * std,
    );

    // Ensure we don't mask everything
    if (!mask.contains(true)) {
      // If all points would be masked, revert to previous iteration
      mask = List.filled(data.length, true);
      break;
    }
  }

  List<double> maskedData = data
      .asMap()
      .entries
      .where((entry) => mask[entry.key])
      .map((entry) => entry.value)
      .toList();

  if (maskedData.isEmpty) {
    return [0.0, 0.0, 0.0];
  }

  double mean =
      maskedData.fold(0.0, (prev, element) => prev + element) /
      maskedData.length;
  double median = _median(maskedData);
  double std = _standardDeviation(maskedData);

  // Debug output can be uncommented if needed
  // print('DEBUG: _sigmaClippedStats: input=${data.length} points, output: mean=${mean.toStringAsFixed(2)}, median=${median.toStringAsFixed(2)}, std=${std.toStringAsFixed(2)}');

  return [mean, median, std];
}

double _median(List<double> data) {
  if (data.isEmpty) return 0.0;

  List<double> sortedData = List.from(data);
  sortedData.sort();
  int midIndex = sortedData.length ~/ 2;
  return sortedData.length.isEven
      ? (sortedData[midIndex - 1] + sortedData[midIndex]) / 2
      : sortedData[midIndex];
}

double _standardDeviation(List<double> data) {
  if (data.isEmpty) return 0.0;

  double mean = data.fold(0.0, (prev, element) => prev + element) / data.length;
  double variance =
      data.fold(0.0, (prev, element) => prev + pow(element - mean, 2)) /
      data.length;
  return sqrt(variance);
}

List<List<double>> _measureMeanLoads(
  List<double> time,
  List<double> forces, {
  double threshold = 7,
}) {
  List<int> raisingEdgesIndex = _getRaisingEdgesIndex(
    forces,
    threshold: threshold,
  );
  List<int> fallingEdgesIndex = _getFallingEdgesIndex(
    forces,
    threshold: threshold,
  );

  List<double> meanLoads = [];
  List<double> durations = [];
  List<double> medianLoads = [];
  List<double> meanTimes = [];
  List<double> errs = [];

  // Debug output can be uncommented if needed
  // print('DEBUG: Processing ${raisingEdgesIndex.length} raising edges and ${fallingEdgesIndex.length} falling edges');
  // print('DEBUG: Original raising edges: $raisingEdgesIndex');
  // print('DEBUG: Original falling edges: $fallingEdgesIndex');

  // If we have one more raising edge than falling edge, add the end as a falling edge
  if (raisingEdgesIndex.length == fallingEdgesIndex.length + 1) {
    fallingEdgesIndex.add(forces.length - 1);
    // print('DEBUG: Added end of data as final falling edge: ${forces.length - 1}');
  }

  // Process each raising edge, finding the corresponding falling edge
  for (var i = 0; i < raisingEdgesIndex.length; i++) {
    var start = raisingEdgesIndex[i];
    int end;

    // Find the first falling edge that comes after this raising edge
    int? correspondingFallingIndex;
    for (int j = 0; j < fallingEdgesIndex.length; j++) {
      if (fallingEdgesIndex[j] > start) {
        correspondingFallingIndex = j;
        break;
      }
    }

    if (correspondingFallingIndex != null) {
      end = fallingEdgesIndex[correspondingFallingIndex];
    } else {
      // No falling edge found, use end of data (common for final interval)
      end = forces.length - 1;
    }

    // Debug output can be uncommented if needed
    // print('DEBUG: Interval $i: start=$start, end=$end');

    // Validate indices
    if (start >= forces.length || end >= forces.length || start >= end) {
      continue;
    }

    var duration = time[end] - time[start];

    // Extract force data for this interval
    List<double> intervalForces = forces.sublist(start, end + 1);

    // Calculate statistics for this interval
    List<double> stats = _sigmaClippedStats(intervalForces);

    // Skip intervals with invalid statistics
    if (stats[0] <= threshold) {
      continue;
    }

    meanLoads.add(stats[0]);
    durations.add(duration);
    medianLoads.add(stats[1]);
    meanTimes.add((time[start] + time[end]) / 2);
    errs.add(stats[2]); // Add standard deviation as error
  }

  return [meanTimes, durations, meanLoads, medianLoads, errs];
}

CriticalForceResults analyseData(
  List<double> t,
  List<double> f,
  double loadTime,
  double restTime, {
  bool interactive = false,
  double start = 0,
}) {
  // Only keep data after start seconds
  List<double> cutT = [];
  List<double> cutF = [];
  final startTime = t[0];
  for (var i = 0; i < t.length; i++) {
    if (t[i] - startTime >= start) {
      cutT.add(t[i]);
      cutF.add(f[i]);
    }
  }
  List<List<double>> results = _measureMeanLoads(cutT, cutF);
  List<double> tmeans = results[0];
  List<double> durations = results[1];
  List<double> fmeans = results[2];
  List<double> eFmeans = results[4];
  double factor = loadTime / (loadTime + restTime);
  // Use last 4 intervals for load asymptote, or all intervals if fewer than 5
  final asymptoteStartIndex = fmeans.length >= 5 ? fmeans.length - 5 : 0;
  final asymptoteEndIndex = fmeans.length >= 5
      ? fmeans.length - 1
      : fmeans.length;
  final asymptoteSublist = fmeans.sublist(
    asymptoteStartIndex,
    asymptoteEndIndex,
  );

  double loadAsymptote =
      asymptoteSublist.reduce((a, b) => a + b) / asymptoteSublist.length;
  double eLoadAsymptote = asymptoteSublist.length > 1
      ? _standardDeviation(asymptoteSublist) / asymptoteSublist.length
      : 0.0;
  double criticalLoad = loadAsymptote * factor;
  // ignore: unused_local_variable
  double eCriticalLoad = criticalLoad * (eLoadAsymptote / loadAsymptote);
  List<double> usedInEachInterval = [];
  List<double> remaining = [];
  for (int i = 0; i < fmeans.length; i++) {
    usedInEachInterval.add(
      (fmeans[i] - criticalLoad) * durations[i] -
          criticalLoad * (loadTime + restTime - durations[i]),
    );
    remaining.add(usedInEachInterval[i]);
    if (i > 0) remaining[i] += remaining[i - 1];
  }
  // ignore: unused_local_variable
  double wprimeAlt = remaining.fold(0, (prev, element) => prev + element);
  double alpha = _median(
    List.generate(
      fmeans.length,
      (index) => (fmeans[index] - loadAsymptote) / remaining[index],
    ),
  );

  List<double> predictedForce = [];
  for (int i = 0; i < remaining.length; i++) {
    predictedForce.add(loadAsymptote + alpha * remaining[i]);
  }

  return CriticalForceResults(
    tmeans: tmeans,
    fmeans: fmeans,
    eFmeans: eFmeans,
    criticalLoad: criticalLoad,
    loadAsymptote: loadAsymptote,
    predictedForce: predictedForce,
  );
}

import 'package:crimpy/models/training_model.dart';

List<RepDataModel> buildRepsData(List<double> avgs, List<RepModel> reps) {
  var i = 0;
  final List<RepDataModel> res = [];
  for (var r in reps) {
    res.add(
      RepDataModel(
        duration: r.durationInSeconds,
        isRest: r.isRest,
        handSide: r.handSide,
        targetWeight: r.targetWeight,
        averageWeight: r.isRest ? 0 : avgs[i],
        index: r.index,
      ),
    );
    if (!r.isRest) {
      i += 1;
    }
  }
  return res;
}

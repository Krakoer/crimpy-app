import 'package:crimpy/models/training_model.dart';

/// Group reps into sets based on the repeater configuration
List<List<RepModel>> groupRepsIntoSets(
  RepeaterModel repeater,
  List<RepModel> reps,
) {
  final sets = <List<RepModel>>[];

  if (repeater.splitHand) {
    // For split hand, each set contains all reps for both hands
    // Pattern: Right hand reps -> rest -> Left hand reps -> rest (between sets)
    final repsPerSet = repeater.repsBySet * 2; // Both hands

    int currentIndex = 0;
    for (int i = 0; i < repeater.sets; i++) {
      final setReps = <RepModel>[];
      int repsCollected = 0;

      // Collect reps until we have enough work reps for this set
      while (currentIndex < reps.length && repsCollected < repsPerSet) {
        final rep = reps[currentIndex];
        if (!rep.isRest) {
          setReps.add(rep);
          repsCollected++;
        }
        currentIndex++;
      }

      sets.add(setReps);

      // Skip rest between sets
      while (currentIndex < reps.length &&
          reps[currentIndex].isRest &&
          reps[currentIndex].durationInSeconds == repeater.restBteweenSets) {
        currentIndex++;
      }
    }
  } else {
    // For alternating hands, each rep is R-rest-L-rest
    // Each set has repsBySet * 2 work reps (R and L for each rep)
    final workRepsPerSet = repeater.repsBySet * 2;

    int currentIndex = 0;
    for (int i = 0; i < repeater.sets; i++) {
      final setReps = <RepModel>[];
      int workRepsCollected = 0;

      // Collect work reps for this set
      while (currentIndex < reps.length && workRepsCollected < workRepsPerSet) {
        final rep = reps[currentIndex];
        if (!rep.isRest) {
          setReps.add(rep);
          workRepsCollected++;
        }
        currentIndex++;
      }

      sets.add(setReps);

      // Skip rest between sets
      while (currentIndex < reps.length &&
          reps[currentIndex].isRest &&
          reps[currentIndex].durationInSeconds == repeater.restBteweenSets) {
        currentIndex++;
        break; // Only skip one set rest
      }
    }
  }

  return sets;
}

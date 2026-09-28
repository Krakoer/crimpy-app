import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/load_drop_alarm.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_drop_alarm_view_model.g.dart';

/// Whether the load of the running rep has dropped below its target, which
/// raises the run screen alarm. The run says which step it is on with
/// [LoadDropAlarmController.follow]; every sensor sample then feeds the rep's
/// [LoadDropAlarm]. A sensor that reconnects mid-rep starts the watch over.
/// See Krakoer/crimpy#175.
@Riverpod(name: 'loadDropAlarmProvider')
class LoadDropAlarmController extends _$LoadDropAlarmController {
  LoadDropAlarm? _rep;

  @override
  bool build() {
    final subscription = ref
        .watch(bleRepositoryProvider)
        .dataStream
        .listen(_onSample);
    ref.onDispose(subscription.cancel);
    ref.listen(connectionStateProvider, (previous, next) {
      if (next == BleConnectionState.connected &&
          previous != BleConnectionState.connected) {
        _rep?.reset();
        state = false;
      }
    });
    return false;
  }

  /// Starts watching [step] afresh, or stops watching when it is null or not a
  /// hang with a target load. A pause stops it too: the stream is down, and
  /// the rep is watched from scratch once the run resumes.
  void follow(TrainingExecutionItem? step) {
    final target = loadDropTargetOf(step);
    _rep = target > 0 ? LoadDropAlarm(target) : null;
    state = false;
  }

  void _onSample(BleDataPoint point) {
    final rep = _rep;
    if (rep == null) return;
    state = rep.update(point.value, point.timestamp);
  }
}

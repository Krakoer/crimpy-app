import 'dart:convert';
import 'dart:io';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the one run that finished and was not saved yet, on the device, so the
/// app dying on its review does not lose it. Krakoer/crimpy#146.
abstract class FinishedRunDraftRepository {
  /// The draft left on the device, or null when there is none or it cannot be
  /// read. One that cannot be read is dropped: it is never offered back, and a
  /// launch never fails over it.
  Future<FinishedRunDraft?> read();

  /// Keeps [draft], in place of any earlier one. There is one draft per
  /// device, whoever it belongs to: a draft of another athlete, which a launch
  /// leaves unoffered, is lost once someone else finishes a run here.
  Future<void> write(FinishedRunDraft draft);

  /// Forgets the draft, once its run is saved or discarded.
  Future<void> clear();
}

/// One JSON file in the app's documents directory. A file rather than the
/// database, which would need a schema step for a record that lives a few
/// minutes, and rather than the preferences, which are not made for the force
/// curve of a Critical Force run.
class FileFinishedRunDraftRepository extends FinishedRunDraftRepository {
  static const _fileName = 'finished_run_draft.json';

  final Future<Directory> Function() _directory;

  FileFinishedRunDraftRepository({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  Future<File> _file() async => File('${(await _directory()).path}/$_fileName');

  @override
  Future<FinishedRunDraft?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString());
      return FinishedRunDraft.fromJson(json as Map<String, dynamic>);
    } catch (error) {
      AppLoggerHelper.warning('Dropping an unreadable run draft: $error');
      await clear();
      return null;
    }
  }

  /// Written beside the draft and renamed over it, so an app killed halfway
  /// through the write leaves the previous draft or the new one, never half of
  /// one.
  @override
  Future<void> write(FinishedRunDraft draft) async {
    final file = await _file();
    final partial = File('${file.path}.partial');
    await partial.writeAsString(jsonEncode(draft.toJson()), flush: true);
    await partial.rename(file.path);
  }

  @override
  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}

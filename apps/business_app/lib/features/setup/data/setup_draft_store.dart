/// Purpose: Persist Setup Wizard progress locally so a killed app resumes
/// mid-wizard (FR-A7: the wizard is resumable).
/// Responsibilities: read/write/clear one JSON draft. Local convenience only —
/// the database's complete_setup() remains the single source of completion.
/// Dependencies: get_storage.
/// Usage: inject SetupDraftStore(); tests inject MemoryDraftStore.
library;

import 'package:get_storage/get_storage.dart';

abstract interface class DraftStore {
  Map<String, dynamic> read();
  void write(Map<String, dynamic> draft);
  void clear();
}

class SetupDraftStore implements DraftStore {
  static const _key = 'setup_wizard_draft';
  final _box = GetStorage();

  @override
  Map<String, dynamic> read() =>
      Map<String, dynamic>.from(_box.read<Map>(_key) ?? {});

  @override
  void write(Map<String, dynamic> draft) => _box.write(_key, draft);

  @override
  void clear() => _box.remove(_key);
}

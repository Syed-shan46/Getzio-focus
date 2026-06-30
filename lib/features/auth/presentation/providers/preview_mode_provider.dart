import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';

class PreviewModeNotifier extends StateNotifier<bool> {
  final HiveDatabase _hiveDb;

  PreviewModeNotifier(this._hiveDb) : super(_hiveDb.getIsPreviewMode() ?? false);

  Future<void> setPreviewMode(bool isPreview) async {
    await _hiveDb.saveIsPreviewMode(isPreview);
    state = isPreview;
  }
}

final previewModeProvider = StateNotifierProvider<PreviewModeNotifier, bool>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return PreviewModeNotifier(hiveDb);
});

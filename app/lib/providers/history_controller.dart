import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'providers.dart';

final historyControllerProvider =
    StateNotifierProvider<HistoryController, AsyncValue<List<Consultation>>>(
  (ref) => HistoryController(ref),
);

class HistoryController extends StateNotifier<AsyncValue<List<Consultation>>> {
  HistoryController(this._ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncLoading();
    final api = _ref.read(apiServiceProvider);
    final local = _ref.read(localStorageProvider);

    try {
      final items = await api.fetchHistory();
      for (final item in items) {
        await local.saveConsultation(item);
      }
      state = AsyncData(items);
    } catch (_) {
      final localItems = local.loadConsultations();
      state = AsyncData(localItems);
    }
  }

  Future<void> deleteConsultation(String id) async {
    final api = _ref.read(apiServiceProvider);
    final local = _ref.read(localStorageProvider);

    final current = state.value ?? [];
    state = AsyncData(current.where((item) => item.consultationId != id).toList());

    await local.deleteConsultation(id);
    try {
      await api.deleteConsultation(id);
    } catch (_) {
      // Keep local delete; server cleanup can be retried later.
    }
  }
}

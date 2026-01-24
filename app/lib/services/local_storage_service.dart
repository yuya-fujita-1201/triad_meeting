import 'package:hive_flutter/hive_flutter.dart';

import '../models/consultation.dart';

class LocalStorageService {
  static const String _consultationBoxKey = 'consultations';
  static const String _prefsBoxKey = 'prefs';

  late Box<String> _consultationBox;
  late Box _prefsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _consultationBox = await Hive.openBox<String>(_consultationBoxKey);
    _prefsBox = await Hive.openBox(_prefsBoxKey);
  }

  List<Consultation> loadConsultations() {
    return _consultationBox.values
        .map(Consultation.fromStorageString)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveConsultation(Consultation consultation) async {
    await _consultationBox.put(
      consultation.consultationId,
      consultation.toStorageString(),
    );
  }

  Future<void> deleteConsultation(String id) async {
    await _consultationBox.delete(id);
  }

  Future<void> clearAll() async {
    await _consultationBox.clear();
    await _prefsBox.clear();
  }

  int incrementConsultationCount() {
    final current = _prefsBox.get('consultationCount', defaultValue: 0) as int;
    final next = current + 1;
    _prefsBox.put('consultationCount', next);
    return next;
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/consultation.dart';

class LocalStorageService {
  static const String _consultationBoxKey = 'consultations';
  static const String _prefsBoxKey = 'prefs';
  static const String _deviceIdKey = 'deviceId';
  static const String _aiConsentKey = 'aiDataSharingConsent';

  late Box<String> _consultationBox;
  late Box _prefsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _consultationBox = await Hive.openBox<String>(_consultationBoxKey);
    _prefsBox = await Hive.openBox(_prefsBoxKey);

    // デバイスIDが存在しない場合は生成して保存
    if (!_prefsBox.containsKey(_deviceIdKey)) {
      final deviceId = const Uuid().v4();
      await _prefsBox.put(_deviceIdKey, deviceId);
    }
  }

  /// 端末固有のデバイスIDを取得
  /// アカウント登録していない匿名ユーザーを識別するために使用
  String getDeviceId() {
    return _prefsBox.get(_deviceIdKey, defaultValue: const Uuid().v4()) as String;
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

  /// AIデータ共有への同意状態を取得
  bool get hasAiConsent {
    return _prefsBox.get(_aiConsentKey, defaultValue: false) as bool;
  }

  /// AIデータ共有への同意を保存
  Future<void> setAiConsent(bool value) async {
    await _prefsBox.put(_aiConsentKey, value);
  }
}

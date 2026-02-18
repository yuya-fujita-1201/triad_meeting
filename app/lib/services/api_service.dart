import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/app_config.dart';
import '../models/consultation.dart';
import 'local_storage_service.dart';

class ApiService {
  ApiService(this._localStorage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: '${AppConfig.apiBaseUrl}/v1',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = _currentUser();
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final LocalStorageService _localStorage;

  User? _currentUser() {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser;
  }

  /// ユーザーIDを取得（Firebase認証済みの場合はuid、未認証の場合はデバイスID）
  String _getUserId() {
    final user = _currentUser();
    if (user != null) {
      return user.uid;
    }
    // 匿名ユーザーの場合は端末固有のデバイスIDを使用
    return _localStorage.getDeviceId();
  }

  Future<Consultation> deliberate(String consultation, {bool isPremium = false}) async {
    try {
      final data = <String, dynamic>{
        'consultation': consultation,
        'plan': isPremium ? 'premium' : 'free',
        'userId': _getUserId(),
      };
      final response = await _dio.post<Map<String, dynamic>>(
        '/deliberate',
        data: data,
      );
      final responseData = response.data ?? {};
      return Consultation.fromJson({
        ...responseData,
        'question': consultation,
      });
    } on DioException catch (error) {
      if (error.response?.statusCode == 429) {
        final errorBody = error.response?.data as Map<String, dynamic>? ?? {};
        throw DailyLimitExceededException(
          errorBody['error']?['message']?.toString() ??
              '本日の無料相談回数（10回）を超えました。',
          resetAt: errorBody['error']?['resetAt']?.toString(),
        );
      }
      throw ApiException(
        error.response?.statusCode,
        error.message ?? '通信エラーが発生しました。',
      );
    }
  }

  Future<List<Consultation>> fetchHistory({int limit = 10, int offset = 0}) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'userId': _getUserId(),
      };
      final response = await _dio.get<Map<String, dynamic>>(
        '/history',
        queryParameters: params,
      );
      final data = response.data ?? {};
      final items = (data['items'] as List<dynamic>?) ??
          (data['consultations'] as List<dynamic>?) ??
          [];
      return items
          .map((item) => Consultation.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusCode,
        error.message ?? '履歴取得に失敗しました。',
      );
    }
  }

  Future<Consultation> fetchConsultation(String id) async {
    final params = <String, dynamic>{
      'userId': _getUserId(),
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/consultations/$id',
      queryParameters: params,
    );
    return Consultation.fromJson(response.data ?? {});
  }

  Future<void> saveConsultation(Consultation consultation) async {
    final data = <String, dynamic>{
      'consultation': consultation.toJson(),
      'userId': _getUserId(),
    };
    await _dio.post(
      '/consultations/${consultation.consultationId}/save',
      data: data,
    );
  }

  Future<void> deleteConsultation(String id) async {
    final params = <String, dynamic>{
      'userId': _getUserId(),
    };
    await _dio.delete(
      '/consultations/$id',
      queryParameters: params,
    );
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int? statusCode;
  final String message;
}

class DailyLimitExceededException extends ApiException {
  DailyLimitExceededException(String message, {this.resetAt})
      : super(429, message);

  final String? resetAt;
}

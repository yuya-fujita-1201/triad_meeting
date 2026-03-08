import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/app_config.dart';
import '../models/consultation.dart';

class ApiService {
  ApiService()
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
          final user = await _ensureAuthenticatedUser();
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

  Future<User?> _ensureAuthenticatedUser() async {
    if (Firebase.apps.isEmpty) return null;

    var user = FirebaseAuth.instance.currentUser;
    if (user != null) return user;

    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      return credential.user;
    } catch (_) {
      return null;
    }
  }

  Future<Consultation> deliberate(
    String consultation, {
    bool isPremium = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'consultation': consultation,
        'plan': isPremium ? 'premium' : 'free',
      };
      final response = await _dio.post<Map<String, dynamic>>(
        '/deliberate',
        data: data,
      );
      final responseData = response.data ?? {};
      return Consultation.fromJson({...responseData, 'question': consultation});
    } on DioException catch (error) {
      final serverMessage = _extractErrorMessage(error);
      if (error.response?.statusCode == 429) {
        final errorBody = error.response?.data as Map<String, dynamic>? ?? {};
        throw DailyLimitExceededException(
          errorBody['error']?['message']?.toString() ?? '本日の無料相談回数（10回）を超えました。',
          resetAt: errorBody['error']?['resetAt']?.toString(),
        );
      }
      if (error.response?.statusCode == 401) {
        throw ApiException(401, '認証に失敗しました。アプリを再起動してください。');
      }
      throw ApiException(
        error.response?.statusCode,
        serverMessage ?? '通信エラーが発生しました。',
      );
    }
  }

  Future<List<Consultation>> fetchHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{'limit': limit, 'offset': offset};
      final response = await _dio.get<Map<String, dynamic>>(
        '/history',
        queryParameters: params,
      );
      final data = response.data ?? {};
      final items =
          (data['items'] as List<dynamic>?) ??
          (data['consultations'] as List<dynamic>?) ??
          [];
      return items
          .map((item) => Consultation.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusCode,
        _extractErrorMessage(error) ?? '履歴取得に失敗しました。',
      );
    }
  }

  Future<Consultation> fetchConsultation(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/consultations/$id');
    return Consultation.fromJson(response.data ?? {});
  }

  Future<void> saveConsultation(Consultation consultation) async {
    final data = <String, dynamic>{'consultation': consultation.toJson()};
    await _dio.post(
      '/consultations/${consultation.consultationId}/save',
      data: data,
    );
  }

  Future<void> deleteConsultation(String id) async {
    await _dio.delete('/consultations/$id');
  }
}

String? _extractErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final nestedError = data['error'];
    if (nestedError is Map<String, dynamic>) {
      final nestedMessage = nestedError['message']?.toString();
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }

    final directError = data['error']?.toString();
    if (directError != null && directError.isNotEmpty) {
      return directError;
    }

    final message = data['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }

  if (data is String && data.isNotEmpty) {
    return data;
  }

  return error.message;
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

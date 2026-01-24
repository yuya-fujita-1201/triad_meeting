import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          final user = FirebaseAuth.instance.currentUser;
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

  Future<Consultation> deliberate(String consultation) async {
    try {
      final data = <String, dynamic>{
        'consultation': consultation,
        'plan': 'free',
      };
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        data['userId'] = userId;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/deliberate',
        data: data,
      );
      final data = response.data ?? {};
      return Consultation.fromJson({
        ...data,
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
      };
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        params['userId'] = userId;
      }
      final response = await _dio.get<Map<String, dynamic>>(
        '/history',
        queryParameters: params,
      );
      final data = response.data ?? {};
      final items = data['items'] as List<dynamic>? ?? [];
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
    final params = <String, dynamic>{};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      params['userId'] = userId;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/consultations/$id',
      queryParameters: params,
    );
    return Consultation.fromJson(response.data ?? {});
  }

  Future<void> saveConsultation(Consultation consultation) async {
    final data = <String, dynamic>{'consultation': consultation.toJson()};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      data['userId'] = userId;
    }
    await _dio.post(
      '/consultations/${consultation.consultationId}/save',
      data: data,
    );
  }

  Future<void> deleteConsultation(String id) async {
    final params = <String, dynamic>{};
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      params['userId'] = userId;
    }
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

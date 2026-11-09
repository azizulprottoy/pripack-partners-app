import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData;
import '../../app/routes/routes_path.dart';
import '../storage/session_storage.dart';
import '../utils/constants.dart';

class DioClient extends GetxService {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (Get.isRegistered<SessionStorage>()) {
            final token = Get.find<SessionStorage>().token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401 && Get.currentRoute != RoutesPath.login) {
            if (Get.isRegistered<SessionStorage>()) {
              Get.find<SessionStorage>().clear();
            }
            Get.offAllNamed(RoutesPath.login);
          }
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return dio.put<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) {
    return dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return dio.delete<T>(path);
  }
}

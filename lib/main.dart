import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/app.dart';
import 'core/network/dio_client.dart';
import 'core/storage/session_storage.dart';
import 'core/utils/app_logger.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error('FlutterError: ${details.exceptionAsString()}', details.exception, details.stack);
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Uncaught PlatformDispatcher error', error, stack);
      return true;
    };

    // Initialize persistent key-value storage
    await GetStorage.init();

    // Core background services
    Get.put(SessionStorage(), permanent: true);
    Get.put(DioClient(), permanent: true);

    runApp(const PripackSellerApp());
  }, (error, stack) {
    AppLogger.error('Uncaught zone error', error, stack);
  });
}

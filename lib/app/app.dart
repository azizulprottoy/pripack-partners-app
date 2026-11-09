import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/constants.dart';
import '../res/theme/app_theme.dart';
import 'routes/routes.dart';

class PripackSellerApp extends StatelessWidget {
  const PripackSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}

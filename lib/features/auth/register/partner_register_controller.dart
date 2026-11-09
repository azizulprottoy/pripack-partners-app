import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/geo_model.dart';
import '../../../shared/widgets/image_source_sheet.dart';
import '../../../shared/widgets/snack_message.dart';
import '../auth_repository.dart';

class PartnerRegisterController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final ImagePicker _picker = ImagePicker();

  final role = AppConstants.roleSeller.obs; // 'seller' or 'supplier'

  final nameController = TextEditingController();
  final shopNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();

  final districts = <DistrictModel>[].obs;
  final selectedDistrictId = ''.obs;

  final categories = <CategoryModel>[].obs;
  final selectedCategories = <String>[].obs;

  final Rx<File?> nidFront = Rx<File?>(null);
  final Rx<File?> nidBack = Rx<File?>(null);
  final Rx<File?> shopPic = Rx<File?>(null);

  final isLoading = false.obs;
  final isFetchingOptions = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['role'] != null) {
      role.value = args['role'].toString();
    }
    loadOptions();
  }

  @override
  void onClose() {
    nameController.dispose();
    shopNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> loadOptions() async {
    isFetchingOptions.value = true;
    try {
      final dList = await _authRepo.getDistricts();
      districts.assignAll(dList);
      if (dList.isNotEmpty) {
        selectedDistrictId.value = dList.first.id;
      }

      final cList = await _authRepo.getCategories();
      categories.assignAll(cList);
    } catch (e, st) {
      AppLogger.error('PartnerRegisterController.loadOptions failed', e, st);
    }
    isFetchingOptions.value = false;
  }

  Future<void> pickImage(String which) async {
    final source = await ImageSourceSheet.show();
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      if (which == 'nidFront') nidFront.value = file;
      if (which == 'nidBack') nidBack.value = file;
      if (which == 'shopPic') shopPic.value = file;
    }
  }

  void toggleCategory(String catName) {
    if (selectedCategories.contains(catName)) {
      selectedCategories.remove(catName);
    } else {
      selectedCategories.add(catName);
    }
  }

  Future<void> register() async {
    if (nameController.text.trim().isEmpty) {
      SnackMessage.error('Please enter your full name.');
      return;
    }
    if (shopNameController.text.trim().isEmpty) {
      SnackMessage.error('Please enter your business/shop name.');
      return;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
      SnackMessage.error('Please enter a valid email address.');
      return;
    }
    if (phoneController.text.trim().length < 8) {
      SnackMessage.error('Please enter a valid phone number.');
      return;
    }
    if (passwordController.text.length < 6) {
      SnackMessage.error('Password must be at least 6 characters.');
      return;
    }
    if (selectedDistrictId.value.isEmpty) {
      SnackMessage.error('Please select your district.');
      return;
    }
    if (addressController.text.trim().isEmpty) {
      SnackMessage.error('Please enter your full address.');
      return;
    }
    if (selectedCategories.isEmpty) {
      SnackMessage.error('Please select at least one product category.');
      return;
    }
    if (nidFront.value == null || nidBack.value == null) {
      SnackMessage.error('Please upload both sides of your National ID (NID).');
      return;
    }
    if (shopPic.value == null) {
      SnackMessage.error('Please upload a picture of your shop / business.');
      return;
    }

    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'name': nameController.text.trim(),
        'shopName': shopNameController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'districtId': selectedDistrictId.value,
        'address': addressController.text.trim(),
        'categories': jsonEncode(selectedCategories.toList()),
        'nidFront': await dio.MultipartFile.fromFile(
          nidFront.value!.path,
          filename: nidFront.value!.path.split('/').last,
        ),
        'nidBack': await dio.MultipartFile.fromFile(
          nidBack.value!.path,
          filename: nidBack.value!.path.split('/').last,
        ),
        'shopPic': await dio.MultipartFile.fromFile(
          shopPic.value!.path,
          filename: shopPic.value!.path.split('/').last,
        ),
      });

      final res = role.value == AppConstants.roleSeller
          ? await _authRepo.registerSeller(formData)
          : await _authRepo.registerSupplier(formData);

      if (res['success'] == true) {
        SnackMessage.success(
          'Registration submitted successfully! You can log in once reviewed by admin.',
        );
        Get.back();
      } else {
        SnackMessage.error(res['message']?.toString() ?? 'Registration failed.');
      }
    } catch (e) {
      SnackMessage.error('Failed to submit registration. Check server status.');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';

class SessionStorage extends GetxService {
  final GetStorage _box = GetStorage();

  String? get token => _box.read<String>(AppConstants.authTokenKey);

  Map<String, dynamic>? get user {
    final raw = _box.read<String>(AppConstants.authUserKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.error('SessionStorage.user failed', e, st);
      return null;
    }
  }

  String get activeRole {
    final saved = _box.read<String>(AppConstants.authRoleKey);
    if (saved != null && saved.isNotEmpty) return saved;
    // Derive from user atype or role
    final u = user;
    if (u != null) {
      if (u['atype'] == AppConstants.roleSeller) return AppConstants.roleSeller;
      if (u['atype'] == AppConstants.roleSupplier) return AppConstants.roleSupplier;
      if (u['role'] != null || u['remail'] != null) return AppConstants.roleAdmin;
    }
    return AppConstants.roleSeller;
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty && user != null;

  bool get isSeller => activeRole == AppConstants.roleSeller;
  bool get isSupplier => activeRole == AppConstants.roleSupplier;
  bool get isAdmin => activeRole == AppConstants.roleAdmin;

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
    required String role,
  }) async {
    await _box.write(AppConstants.authTokenKey, token);
    await _box.write(AppConstants.authUserKey, jsonEncode(user));
    await _box.write(AppConstants.authRoleKey, role);
  }

  Future<void> updateUserData(Map<String, dynamic> partialData) async {
    final current = user ?? {};
    current.addAll(partialData);
    await _box.write(AppConstants.authUserKey, jsonEncode(current));
  }

  Future<void> switchRole(String newRole) async {
    await _box.write(AppConstants.authRoleKey, newRole);
  }

  Future<void> clear() async {
    await _box.remove(AppConstants.authTokenKey);
    await _box.remove(AppConstants.authUserKey);
    await _box.remove(AppConstants.authRoleKey);
  }
}

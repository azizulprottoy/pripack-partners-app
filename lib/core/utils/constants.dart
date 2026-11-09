import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const String appName = 'Pripack Seller';

  /// Backend has no API prefix — every route is a bare path off this host.
  /// Android emulator uses 10.0.2.2; iOS simulator / Web use localhost.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001';
    return 'http://localhost:5001';
  }

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String authUserKey = 'auth_user';
  static const String authRoleKey = 'auth_role'; // 'seller' | 'supplier' | 'admin'

  // Profile Roles
  static const String roleSeller = 'seller';
  static const String roleSupplier = 'supplier';
  static const String roleAdmin = 'admin';

  // Partner Statuses
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusSuspended = 'suspended';

  // Seller Order Statuses
  static const String orderPending = 'Pending Verification';
  static const String orderTransferred = 'Transferred to Supplier';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';

  // Supplier Job Statuses
  static const String jobAssigned = 'Assigned';
  static const String jobInProduction = 'In Production';
  static const String jobPickupRequested = 'Pickup Requested';
  static const String jobPickedUp = 'Picked Up';
}

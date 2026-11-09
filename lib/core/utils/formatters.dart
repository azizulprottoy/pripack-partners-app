import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String taka(num? value) {
    final amount = value ?? 0;
    final formatter = NumberFormat('#,##,###.##', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  static String formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  static String formatDateTime(dynamic date) {
    if (date == null) return '';
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'delivered':
      case 'picked up':
        return const Color(0xFF10B981); // Emerald green
      case 'pending':
      case 'pending verification':
      case 'assigned':
        return const Color(0xFFF59E0B); // Amber
      case 'in production':
      case 'transferred to supplier':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'pickup requested':
        return const Color(0xFF6366F1); // Indigo
      case 'rejected':
      case 'cancelled':
      case 'suspended':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}

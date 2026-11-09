import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF14B8A6); // Teal-500
  static const Color primaryDark = Color(0xFF0F766E); // Teal-700
  static const Color cyan = Color(0xFF06B6D4); // Cyan-500
  static const Color indigo = Color(0xFF6366F1); // Indigo-500
  static const Color emerald = Color(0xFF10B981); // Emerald-500
  static const Color amber = Color(0xFFF59E0B); // Amber-500
  static const Color rose = Color(0xFFF43F5E); // Rose-500

  static const Color textDark = Color(0xFF0F172A); // Slate-900
  static const Color textNormal = Color(0xFF1E293B); // Slate-800
  static const Color textMuted = Color(0xFF64748B); // Slate-500
  static const Color textLight = Color(0xFF94A3B8); // Slate-400

  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color inputBg = Color(0xFFF1F5F9); // Slate-100

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const List<Color> primaryGradient = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFF14B8A6), // Teal
  ];

  static const List<Color> heroGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
  ];
}

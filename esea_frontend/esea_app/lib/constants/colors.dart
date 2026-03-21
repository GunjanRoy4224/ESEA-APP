import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF10B981); // Emerald-600
  static const Color primaryDark = Color(0xFF059669); // Emerald-700
  static const Color primaryLight = Color(0xFF34D399); // Emerald-500
  
  // Background Colors
  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFF3F4F6); // Gray-100
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-600
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB); // Gray-200
  static const Color borderDark = Color(0xFFD1D5DB); // Gray-300
  
  // Feature/Category Colors
  static const Color purple = Color(0xFF9333EA);
  static const Color purpleLight = Color(0xFFF3E8FF);
  
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDCE9FF);
  
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFFE0E7FF);
  
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFCE7F3);
  
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);
  
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);
  
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);
  
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFEDD5);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Shadow
  static Color shadow = Colors.black.withValues(alpha: 0.1);
  static Color shadowDark = Colors.black.withValues(alpha: 0.2);
}
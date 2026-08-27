import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Palette
  static const darkBackground = Color(0xFF0F172A);
  static const darkCardBackground = Color(0xFF1E293B);
  static const darkCardBorder = Color(0xFF334155);
  static const darkSidebarBackground = Color(0xFF0B1120);

  // Light Theme Palette (Clean & High Contrast)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFE2E8F0);
  static const lightSidebarBackground = Color(0xFFFFFFFF);

  // Brand Primaries
  static const darkPrimary = Color(0xFF38BDF8); // Sky Blue 400
  static const lightPrimary = Color(0xFF0284C7); // Sky Blue 600

  // Severity Colors (Dark Mode)
  static const darkCritical = Color(0xFFF87171);
  static const darkHigh = Color(0xFFFB923C);
  static const darkMedium = Color(0xFFFBBF24);
  static const darkLow = Color(0xFF60A5FA);
  static const darkInfo = Color(0xFF2DD4BF);

  // Severity Colors (Light Mode - Stronger Contrast)
  static const lightCritical = Color(0xFFDC2626);
  static const lightHigh = Color(0xFFEA580C);
  static const lightMedium = Color(0xFFD97706);
  static const lightLow = Color(0xFF2563EB);
  static const lightInfo = Color(0xFF0D9488);

  // Code & Fix Box Colors
  static Color codeBoxBackground(bool isDark) =>
      isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9);

  static Color vulnerableBoxBackground(bool isDark) =>
      isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);

  static Color vulnerableBoxBorder(bool isDark) =>
      isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5);

  static Color vulnerableBoxText(bool isDark) =>
      isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);

  static Color secureBoxBackground(bool isDark) =>
      isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4);

  static Color secureBoxBorder(bool isDark) =>
      isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC);

  static Color secureBoxText(bool isDark) =>
      isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);

  static Color brandPrimary(bool isDark) =>
      isDark ? darkPrimary : lightPrimary;

  static Color brandSecondary(bool isDark) =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
}

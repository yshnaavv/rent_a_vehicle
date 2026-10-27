import 'package:flutter/material.dart';

/// App color palette featuring Turmeric (#FFBE0B) and Malt (#2A2312)
class AppColors {
  // Primary brand colors
  static const Color turmeric = Color(0xFFFFBE0B);
  static const Color turmericDark = Color(0xFFE5A800);
  static const Color turmericLight = Color(0xFFFFF6D6);
  static const Color turmericSoft = Color(0xFFFEF0C3);

  // Malt brand colors
  static const Color malt = Color(0xFF2A2312);
  static const Color maltDark = Color(0xFF1B160B);
  static const Color maltLight = Color(0xFF3F351E);
  static const Color maltMedium = Color(0xFF554728);
  static const Color maltMuted = Color(0xFF7A6F56);
  static const Color maltBorder = Color(0xFFE5DFD3);

  // Background and surface colors
  static const Color background = Color(0xFFFBF9F5);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF221C0E);

  // Accent & feedback colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);
}

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.turmeric,

      colorScheme: const ColorScheme.light(
        primary: AppColors.malt,
        onPrimary: AppColors.turmeric,
        secondary: AppColors.turmeric,
        onSecondary: AppColors.malt,
        surface: AppColors.surface,
        onSurface: AppColors.malt,
        error: AppColors.error,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.malt,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.turmeric),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turmeric,
          foregroundColor: AppColors.malt,
          elevation: 2,
          shadowColor: AppColors.malt.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.malt,
          side: const BorderSide(color: AppColors.malt, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.malt,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.maltBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.maltBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.turmeric, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.maltMuted),
        hintStyle: TextStyle(color: AppColors.maltMuted.withValues(alpha: 0.7)),
        prefixIconColor: AppColors.malt,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: AppColors.malt.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.maltBorder.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.turmeric,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.malt,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.maltMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.malt);
          }
          return const IconThemeData(color: AppColors.maltMuted);
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.malt,
        selectedItemColor: AppColors.turmeric,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.turmeric,
        foregroundColor: AppColors.malt,
        elevation: 3,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.malt,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.maltBorder,
        thickness: 1,
      ),
    );
  }
}

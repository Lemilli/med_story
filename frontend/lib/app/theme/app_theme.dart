import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cobalt,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.clinicalWhite,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cobalt,
        onPrimary: AppColors.clinicalWhite,
        primaryContainer: AppColors.selectedSurface,
        onPrimaryContainer: AppColors.cobalt,
        secondary: AppColors.deepClinicalBlue,
        surface: AppColors.clinicalWhite,
        onSurface: AppColors.patientInk,
        onSurfaceVariant: AppColors.secondaryInk,
        surfaceContainerHighest: AppColors.quietSurface,
        surfaceContainerLow: AppColors.quietSurface,
        outline: AppColors.inputOutline,
        outlineVariant: AppColors.clinicalLine,
        error: AppColors.error,
      ),
      textTheme: base.textTheme
          .copyWith(
            headlineMedium: const TextStyle(
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: const TextStyle(
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            titleLarge: const TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            titleMedium: const TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: const TextStyle(fontSize: 16, height: 1.55),
            bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
            bodySmall: const TextStyle(fontSize: 13, height: 1.5),
          )
          .apply(
            bodyColor: AppColors.patientInk,
            displayColor: AppColors.patientInk,
          ),
      iconTheme: const IconThemeData(color: AppColors.patientInk, size: 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.clinicalWhite,
        foregroundColor: AppColors.patientInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.patientInk,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.clinicalLine)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.clinicalLine,
        thickness: 1,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.clinicalWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(color: AppColors.clinicalLine),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.clinicalWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.clinicalWhite,
        selectedColor: AppColors.selectedSurface,
        side: const BorderSide(color: AppColors.clinicalLine),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.clinicalWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.inputOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.inputOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.deepClinicalBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.cobalt,
          foregroundColor: AppColors.clinicalWhite,
          disabledBackgroundColor: AppColors.disabledFill,
          disabledForegroundColor: AppColors.secondaryInk,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.cobalt,
          side: const BorderSide(color: AppColors.inputOutline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.cobalt,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.clinicalWhite,
        selectedItemColor: AppColors.cobalt,
        unselectedItemColor: AppColors.secondaryInk,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Source palette in OKLCH:
  // bg oklch(1.000 0.000 0), surface oklch(0.967 0.003 250),
  // ink oklch(0.215 0.018 255), muted oklch(0.465 0.021 255),
  // line oklch(0.890 0.006 255), primary oklch(0.500 0.190 22.7),
  // accent oklch(0.300 0.070 238).
  static const clinicalWhite = Color(0xFFFFFFFF);
  static const quietSurface = Color(0xFFF4F6FA);
  static const patientInk = Color(0xFF0B172A);
  static const secondaryInk = Color(0xFF53627A);
  static const clinicalLine = Color(0xFFD9DFE8);
  static const controlledCrimson = Color(0xFFBA1237);
  static const deepClinicalBlue = Color(0xFF003F9E);
  static const disabledFill = Color(0xFFE8ECF2);
  static const success = Color(0xFF176B43);
  static const warning = Color(0xFF8A5A00);
  static const info = Color(0xFF003F9E);
  static const error = Color(0xFF9E1233);
  static const selectedSurface = Color(0xFFFCEEF1);
}

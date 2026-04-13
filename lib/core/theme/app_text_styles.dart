import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Текстовые стили приложения
class AppTextStyles {
  AppTextStyles._();

  // Заголовки
  static TextStyle get h1 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.25,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Основной текст
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  // Подписи
  static TextStyle get caption => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get overline => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 1.5,
      );

  // Кнопки
  static TextStyle get buttonLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.25,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // Поля ввода
  static TextStyle get input => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get inputHint => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: AppColors.textHint,
      );

  static TextStyle get inputError => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AppColors.error,
      );

  // Специальные
  static TextStyle get price => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get mileage => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get badge => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
      );
}

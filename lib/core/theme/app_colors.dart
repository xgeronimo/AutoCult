import 'package:flutter/material.dart';

/// Цветовая палитра приложения AutoCult
class AppColors {
  AppColors._();

  // Основные цвета (по дизайну Figma)
  static const Color primary = Color(0xFF34C37A);        // Зелёный #34C37A
  static const Color primaryLight = Color(0xFF5DD498);
  static const Color primaryDark = Color(0xFF2AA366);
  
  static const Color secondary = Color(0xFF969696);      // Серый для secondary кнопок #969696
  static const Color secondaryLight = Color(0xFFBDBDBD);
  static const Color secondaryDark = Color(0xFF757575);
  
  // Акцентный цвет
  static const Color accent = Color(0xFFFF6B35);         // Оранжевый акцент
  
  // Фоновые цвета
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Цвет полей ввода (по дизайну Figma)
  static const Color inputBackground = Color(0xFFF4F4F6);  // #F4F4F6
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBorderFocused = Color(0xFF34C37A);
  static const Color inputBorderError = Color(0xFFD41717);  // #D41717
  
  // Цвета карточек
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Текстовые цвета (по дизайну Figma)
  static const Color textPrimaryLight = Color(0xFF000000);   // #000000
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF888888); // #888888
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF888888);           // #888888
  
  // Статусные цвета
  static const Color success = Color(0xFF34C37A);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD41717);    // #D41717 для красных звёздочек
  static const Color info = Color(0xFF2196F3);
  
  // Дополнительные цвета
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  
  // Цвета для категорий расходов
  static const Color expenseFuel = Color(0xFF2196F3);
  static const Color expenseService = Color(0xFF4CAF50);
  static const Color expenseRepair = Color(0xFFE53935);
  static const Color expenseInsurance = Color(0xFF9C27B0);
  static const Color expenseTax = Color(0xFFFFC107);
  static const Color expenseOther = Color(0xFF757575);
  
  // Цвет overlay для модальных окон
  static const Color modalOverlay = Color(0x80000000);
  
  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF34C37A), Color(0xFF5DD498)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

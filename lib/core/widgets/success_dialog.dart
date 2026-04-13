import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonText = 'Продолжить',
    required this.onPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String buttonText = 'Продолжить',
    required VoidCallback onPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalOverlay,
      isScrollControlled: true,
      builder: (_) => SuccessDialog(
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  static Future<void> showRecordAdded(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return show(
      context,
      title: 'Запись добавлена',
      subtitle: 'Отслеживайте свою историю обслуживания\nв карточке автомобиля',
      onPressed: onContinue,
    );
  }

  static Future<void> showRecordUpdated(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return show(
      context,
      title: 'Запись обновлена',
      subtitle: 'Изменения успешно сохранены',
      onPressed: onContinue,
    );
  }

  static Future<void> showExpenseAdded(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return show(
      context,
      title: 'Расход добавлен',
      subtitle: 'Отслеживайте свои расходы\nв разделе статистики',
      onPressed: onContinue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 44.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                width: 56.w,
                height: 60.h,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/check-line.svg',
                    width: 42.w,
                    height: 42.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF09121F),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: 0.38,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                SizedBox(height: 8.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondaryLight,
                    letterSpacing: -0.154,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  factory AppErrorWidget.network({VoidCallback? onRetry}) {
    return AppErrorWidget(
      title: 'Нет подключения',
      message: AppStrings.errorNetwork,
      onRetry: onRetry,
      icon: Icons.wifi_off_outlined,
    );
  }

  factory AppErrorWidget.server({VoidCallback? onRetry}) {
    return AppErrorWidget(
      title: 'Ошибка сервера',
      message: AppStrings.errorServer,
      onRetry: onRetry,
      icon: Icons.cloud_off_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 16.h),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              AppButton(
                text: AppStrings.retry,
                onPressed: onRetry,
                type: AppButtonType.outline,
                size: AppButtonSize.small,
                isFullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

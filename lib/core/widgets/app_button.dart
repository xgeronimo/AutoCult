import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

enum AppButtonType { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget child = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                SizedBox(width: 8.w),
              ],
              if (icon != null) ...[
                Icon(icon, size: 20.sp),
                SizedBox(width: 8.w),
              ],
              Text(text, style: textStyle),
              if (suffixIcon != null) ...[
                SizedBox(width: 8.w),
                suffixIcon!,
              ],
            ],
          );

    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          height: height,
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: child,
          ),
        );

      case AppButtonType.secondary:
        return SizedBox(
          height: height,
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.secondary.withValues(alpha: 0.5),
            ),
            child: child,
          ),
        );

      case AppButtonType.outline:
        return SizedBox(
          height: height,
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              padding: padding,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: child,
          ),
        );

      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(padding: padding),
          child: child,
        );
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40.h;
      case AppButtonSize.medium:
        return 52.h;
      case AppButtonSize.large:
        return 60.h;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600);
    }
  }
}

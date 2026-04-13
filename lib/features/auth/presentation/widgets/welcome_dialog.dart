import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

class WelcomeDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeDialog({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 44.h),
        child: Material(
          color: Colors.transparent,
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
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                    letterSpacing: 0.38,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ваш аккаунт успешно зарегистрирован',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondaryLight,
                    letterSpacing: -0.154,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Продолжить',
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
      ),
    );
  }
}

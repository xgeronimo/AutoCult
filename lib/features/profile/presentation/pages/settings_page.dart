import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  GlassPillButton(
                    iconPath: 'assets/icons/arrow-left-s-line.svg',
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Безопасность'),
                    SizedBox(height: 8.h),
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Сменить пароль',
                      onTap: () => context.push(AppRoutes.changePassword),
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('О приложении'),
                    SizedBox(height: 8.h),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Версия приложения',
                      trailing: Text(
                        AppConstants.appVersion,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      label: 'Политика конфиденциальности',
                      onTap: () {},
                    ),
                    SizedBox(height: 8.h),
                    _buildMenuItem(
                      icon: Icons.article_outlined,
                      label: 'Условия использования',
                      onTap: () {},
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.w, color: const Color(0xFF09121F)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 24.w,
                color: AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushEnabled = true;
  bool _serviceReminders = true;
  bool _insuranceReminders = true;
  bool _inspectionReminders = true;

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
                      'Уведомления',
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
                    _buildSectionTitle('Основные'),
                    SizedBox(height: 8.h),
                    _buildSwitchItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Push-уведомления',
                      subtitle: 'Получать уведомления на устройство',
                      value: _pushEnabled,
                      onChanged: (val) => setState(() => _pushEnabled = val),
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Напоминания'),
                    SizedBox(height: 8.h),
                    _buildSwitchItem(
                      icon: Icons.build_outlined,
                      label: 'Напоминания о ТО',
                      subtitle: 'Плановое техническое обслуживание',
                      value: _serviceReminders,
                      onChanged: _pushEnabled
                          ? (val) => setState(() => _serviceReminders = val)
                          : null,
                    ),
                    SizedBox(height: 8.h),
                    _buildSwitchItem(
                      icon: Icons.shield_outlined,
                      label: 'Страховка',
                      subtitle: 'Окончание срока действия полиса',
                      value: _insuranceReminders,
                      onChanged: _pushEnabled
                          ? (val) => setState(() => _insuranceReminders = val)
                          : null,
                    ),
                    SizedBox(height: 8.h),
                    _buildSwitchItem(
                      icon: Icons.assignment_outlined,
                      label: 'Техосмотр',
                      subtitle: 'Приближающийся срок техосмотра',
                      value: _inspectionReminders,
                      onChanged: _pushEnabled
                          ? (val) => setState(() => _inspectionReminders = val)
                          : null,
                    ),
                    SizedBox(height: 24.h),
                    if (!_pushEnabled)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warning,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Включите push-уведомления, чтобы не пропустить важные напоминания',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildSwitchItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final isDisabled = onChanged == null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
            child: Icon(
              icon,
              size: 20.w,
              color: isDisabled
                  ? AppColors.textSecondaryLight.withValues(alpha: 0.5)
                  : const Color(0xFF09121F),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? AppColors.textSecondaryLight
                        : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24.h,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

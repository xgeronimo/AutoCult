import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reminder_entity.dart';

class ReminderTile extends StatelessWidget {
  final ReminderEntity reminder;

  const ReminderTile({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: reminder.isRead
            ? AppColors.inputBackground
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: reminder.isRead
            ? null
            : Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: reminder.isRead
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!reminder.isRead && reminder.isPast) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (reminder.body != null && reminder.body!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    reminder.body!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14.w,
                      color: reminder.isPast
                          ? AppColors.textSecondaryLight
                          : AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDateTime(reminder.scheduledAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: reminder.isPast
                            ? AppColors.textSecondaryLight
                            : AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeBadgeColor(reminder.type)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        reminder.type.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: _getTypeBadgeColor(reminder.type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: _getTypeBadgeColor(reminder.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        _getTypeIcon(reminder.type),
        size: 20.w,
        color: _getTypeBadgeColor(reminder.type),
      ),
    );
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.custom:
        return Icons.notifications_none_rounded;
      case ReminderType.service:
        return Icons.build_outlined;
      case ReminderType.insurance:
        return Icons.shield_outlined;
      case ReminderType.inspection:
        return Icons.assignment_outlined;
    }
  }

  Color _getTypeBadgeColor(ReminderType type) {
    switch (type) {
      case ReminderType.custom:
        return AppColors.info;
      case ReminderType.service:
        return AppColors.primary;
      case ReminderType.insurance:
        return const Color(0xFF9C27B0);
      case ReminderType.inspection:
        return AppColors.accent;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (date == today) return 'Сегодня, $timeStr';
    if (date == tomorrow) return 'Завтра, $timeStr';

    if (dateTime.year != now.year) {
      return '${DateFormat('d MMM yyyy', 'ru_RU').format(dateTime)}, $timeStr';
    }
    return '${DateFormat('d MMM', 'ru_RU').format(dateTime)}, $timeStr';
  }
}

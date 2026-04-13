import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/entities/expense_entity.dart';

class ExpenseCategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback? onTap;

  const ExpenseCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _categoryColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 8.w),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: colors.$1,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  _iconPath,
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    colors.$2,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  /// (backgroundColor, iconColor)
  (Color, Color) get _categoryColors {
    switch (category) {
      case ExpenseCategory.fuel:
        return (const Color(0xFFDCEEFB), const Color(0xFF4A90D9));
      case ExpenseCategory.parking:
        return (const Color(0xFFE8E0F5), const Color(0xFF7B61C2));
      case ExpenseCategory.fines:
        return (const Color(0xFFFDE0E0), const Color(0xFFD45B5B));
      case ExpenseCategory.tollRoad:
        return (const Color(0xFFDAF0D8), const Color(0xFF5BA854));
      case ExpenseCategory.wash:
        return (const Color(0xFFD8EEFC), const Color(0xFF5BA0D4));
      case ExpenseCategory.carCare:
        return (const Color(0xFFFDE8D4), const Color(0xFFD48A4A));
      case ExpenseCategory.accessories:
        return (const Color(0xFFF3DAE8), const Color(0xFFC26B8F));
      case ExpenseCategory.taxes:
        return (const Color(0xFFFFF3D4), const Color(0xFFBFA034));
      case ExpenseCategory.insurance:
        return (const Color(0xFFDCF0DA), const Color(0xFF5FA85A));
      case ExpenseCategory.other:
        return (const Color(0xFFE8E8E8), const Color(0xFF8A8A8A));
    }
  }

  String get _iconPath {
    switch (category) {
      case ExpenseCategory.fuel:
        return 'assets/icons/charging-pile-fill.svg';
      case ExpenseCategory.parking:
        return 'assets/icons/parking-fill.svg';
      case ExpenseCategory.fines:
        return 'assets/icons/traffic-light-fill.svg';
      case ExpenseCategory.tollRoad:
        return 'assets/icons/route-fill.svg';
      case ExpenseCategory.wash:
        return 'assets/icons/drop-fill.svg';
      case ExpenseCategory.carCare:
        return 'assets/icons/brush-fill.svg';
      case ExpenseCategory.accessories:
        return 'assets/icons/magic-fill.svg';
      case ExpenseCategory.taxes:
        return 'assets/icons/bank-fill.svg';
      case ExpenseCategory.insurance:
        return 'assets/icons/magic-fill.svg';
      case ExpenseCategory.other:
        return 'assets/icons/bank-fill.svg';
    }
  }
}

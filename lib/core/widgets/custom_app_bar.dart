import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Row(
          children: [
            if (showBackButton)
              GlassPillButton(
                iconPath: 'assets/icons/arrow-left-s-line.svg',
                onTap: onBackPressed ?? () => context.pop(),
              )
            else
              SizedBox(width: 44.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else
              SizedBox(width: 44.w),
          ],
        ),
      ),
    );
  }
}

class GlassPillButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  final double? size;

  const GlassPillButton({
    super.key,
    required this.iconPath,
    required this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 44.w;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24.w,
            height: 24.w,
            colorFilter: const ColorFilter.mode(
              Color(0xFF09121F),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

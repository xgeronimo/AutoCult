import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const AuthTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.isRequired = true,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 51.h,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            readOnly: readOnly,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: hasError
                    ? const BorderSide(color: AppColors.error, width: 1.5)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

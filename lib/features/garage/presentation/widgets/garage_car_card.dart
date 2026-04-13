import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/car_entity.dart';

class GarageCarCard extends StatelessWidget {
  final CarEntity car;
  final VoidCallback? onTap;

  const GarageCarCard({
    super.key,
    required this.car,
    this.onTap,
  });

  bool get _hasPhoto => car.photoUrl != null && car.photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _hasPhoto ? _buildPhotoCard() : _buildPlaceholderCard(),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.8.r),
        child: Container(
          color: AppColors.inputBackground,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.network(
                  car.photoUrl!,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => Image.asset(
                    car.bodyType.imagePath,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.inputBackground,
                        AppColors.inputBackground,
                        AppColors.inputBackground.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 0.55, 0.7],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                top: 16.h,
                child: _buildTextContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.8.r),
        child: Container(
          color: AppColors.inputBackground,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: _buildTextContent(),
                ),
              ),
              SizedBox(
                width: 140.w,
                child: Image.asset(
                  car.bodyType.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          car.fullName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${car.year}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        if (car.licensePlate != null && car.licensePlate!.isNotEmpty)
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              car.licensePlate!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
      ],
    );
  }
}

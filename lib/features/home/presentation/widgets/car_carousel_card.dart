import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../garage/domain/entities/car_entity.dart';

class CarCarouselCard extends StatelessWidget {
  final CarEntity car;
  final VoidCallback? onTap;

  const CarCarouselCard({
    super.key,
    required this.car,
    this.onTap,
  });

  bool get _hasPhoto => car.photoUrl != null && car.photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
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
              child: _buildCarImage(),
            ),
            if (_hasPhoto)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.inputBackground,
                        AppColors.inputBackground.withValues(alpha: 0.85),
                        AppColors.inputBackground.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
                Positioned(
                  left: 20.w,
                  top: 20.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.fullName,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${car.year}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (car.licensePlate != null &&
                          car.licensePlate!.isNotEmpty)
                        _buildLicensePlate(car.licensePlate!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    if (car.photoUrl != null && car.photoUrl!.isNotEmpty) {
      return Image.network(
        car.photoUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      car.bodyType.imagePath,
      fit: BoxFit.contain,
      alignment: Alignment.bottomRight,
    );
  }

  Widget _buildLicensePlate(String plate) {
    final parts = _parsePlate(plate);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            parts.$1,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),
          if (parts.$2.isNotEmpty) ...[
            SizedBox(width: 4.w),
            Text(
              parts.$2,
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (String, String) _parsePlate(String plate) {
    final regionMatch = RegExp(r'(\d{2,3})$').firstMatch(plate);
    if (regionMatch != null) {
      final region = regionMatch.group(0)!;
      final main = plate.substring(0, plate.length - region.length).trim();
      return (main, region);
    }
    return (plate, '');
  }
}

class AddCarCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AddCarCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
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
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Добавить\nавтомобиль',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Нажмите, чтобы добавить\nваш первый автомобиль',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondaryLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 28.w),
              child: Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30.w,
                    ),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<String?> pickFromGallery({int imageQuality = 85}) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    return _validateAndReturn(image);
  }

  Future<String?> pickFromCamera({int imageQuality = 85}) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    return _validateAndReturn(image);
  }

  Future<List<String>> pickMultipleFromGallery({int imageQuality = 85}) async {
    final images = await _picker.pickMultiImage(imageQuality: imageQuality);
    final paths = <String>[];
    for (final image in images) {
      final path = _validateAndReturn(image);
      if (path != null) paths.add(path);
    }
    return paths;
  }

  String? _validateAndReturn(XFile? file) {
    if (file == null) return null;

    final fileSize = File(file.path).lengthSync();
    if (fileSize > AppConstants.maxImageSize) return null;

    return file.path;
  }

  /// Показывает bottom sheet для выбора источника (галерея/камера),
  /// затем открывает выбранный источник и возвращает путь к файлу.
  Future<String?> showPickerSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Выберите источник',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  'Галерея',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  'Камера',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    return source == ImageSource.gallery
        ? pickFromGallery()
        : pickFromCamera();
  }
}

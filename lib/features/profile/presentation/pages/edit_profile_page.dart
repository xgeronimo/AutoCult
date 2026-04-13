import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  String? _selectedPhotoPath;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final nameChanged = _nameController.text.trim() != (widget.user.displayName ?? '');
    return nameChanged || _selectedPhotoPath != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          context.read<AuthBloc>().add(const AuthCheckRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Профиль обновлён'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          context.pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
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
                        'Редактирование',
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        _buildAvatarSection(),
                        SizedBox(height: 32.h),
                        AppTextField(
                          controller: _nameController,
                          label: 'Имя',
                          hint: 'Введите ваше имя',
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 16.h),
                        _buildReadOnlyField(
                          label: 'Email',
                          value: widget.user.email,
                        ),
                        SizedBox(height: 16.h),
                        _buildReadOnlyField(
                          label: 'Дата регистрации',
                          value: _formatDate(widget.user.createdAt),
                        ),
                        SizedBox(height: 40.h),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            return AppButton(
                              text: 'Сохранить',
                              onPressed: _hasChanges ? _onSave : null,
                              isLoading: state is ProfileLoading,
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.divider,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatarContent(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Изменить фото',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_selectedPhotoPath != null) {
      return Image.file(
        File(_selectedPhotoPath!),
        width: 100.w,
        height: 100.w,
        fit: BoxFit.cover,
      );
    }

    if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.user.photoUrl!,
        width: 100.w,
        height: 100.w,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildInitialsAvatar(),
        errorWidget: (_, __, ___) => _buildInitialsAvatar(),
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        widget.user.initials,
        style: TextStyle(
          fontSize: 36.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final path = await sl<ImagePickerService>().showPickerSheet(context);
    if (path != null) {
      setState(() => _selectedPhotoPath = path);
    }
  }

  void _onSave() {
    final name = _nameController.text.trim();
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
      userId: widget.user.id,
      displayName: name.isNotEmpty ? name : null,
      photoPath: _selectedPhotoPath,
    ));
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

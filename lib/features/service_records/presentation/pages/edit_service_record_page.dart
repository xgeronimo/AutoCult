import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/photo_viewer_page.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/service_record_entity.dart';
import '../bloc/service_records_bloc.dart';

class EditServiceRecordPage extends StatefulWidget {
  final String carId;
  final ServiceRecordEntity record;

  const EditServiceRecordPage({
    super.key,
    required this.carId,
    required this.record,
  });

  @override
  State<EditServiceRecordPage> createState() => _EditServiceRecordPageState();
}

class _EditServiceRecordPageState extends State<EditServiceRecordPage> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceStationController = TextEditingController();

  late DateTime _selectedDate;
  ServiceCategory? _selectedCategory;
  final List<String> _newPhotoPaths = [];
  late List<String> _existingPhotoUrls;

  String? _titleError;
  String? _categoryError;
  String? _mileageError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _titleController.text = r.title;
    _costController.text = r.cost != null ? r.cost!.toStringAsFixed(0) : '';
    _mileageController.text = r.mileage.toString();
    _descriptionController.text = r.description ?? '';
    _serviceStationController.text = r.serviceStation ?? '';
    _selectedDate = r.date;
    _selectedCategory = r.category;
    _existingPhotoUrls = List.from(r.photoUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    _serviceStationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ServiceRecordsBloc>(),
      child: BlocListener<ServiceRecordsBloc, ServiceRecordsState>(
        listener: (context, state) {
          if (state is ServiceRecordsUpdateSuccess) {
            setState(() => _isLoading = false);
            SuccessDialog.showRecordUpdated(
              context,
              onContinue: () {
                Navigator.of(context).pop();
                context.pop();
              },
            );
          } else if (state is ServiceRecordsError) {
            setState(() => _isLoading = false);
            AppSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const CustomAppBar(title: 'Редактирование'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildTitleField(),
                        SizedBox(height: 16.h),
                        _buildCostField(),
                        SizedBox(height: 16.h),
                        _buildCategoryField(),
                        SizedBox(height: 16.h),
                        _buildMileageField(),
                        SizedBox(height: 16.h),
                        _buildDateField(),
                        SizedBox(height: 16.h),
                        _buildDescriptionField(),
                        SizedBox(height: 16.h),
                        _buildPhotosSection(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 41.h,
                    child: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: _isLoading ? null : () => _onSave(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Сохранить',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
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

  Widget _buildTitleField() {
    return _buildTextField(
      controller: _titleController,
      label: 'Название записи',
      hint: 'Например: ТО, Замена масла',
      errorText: _titleError,
      onChanged: (_) {
        if (_titleError != null) setState(() => _titleError = null);
      },
    );
  }

  Widget _buildCostField() {
    return _buildTextField(
      controller: _costController,
      label: 'Стоимость',
      hint: '0 руб.',
      isRequired: false,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildMileageField() {
    return _buildTextField(
      controller: _mileageController,
      label: 'Пробег',
      hint: '0 км',
      errorText: _mileageError,
      keyboardType: TextInputType.number,
      onChanged: (_) {
        if (_mileageError != null) setState(() => _mileageError = null);
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool isRequired = true,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: errorText != null
                ? Border.all(color: AppColors.error, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
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
                color: AppColors.textSecondaryLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Text(
            errorText,
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryField() {
    final hasError = _categoryError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Категория',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            children: [
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
        GestureDetector(
          onTap: _selectCategory,
          child: Container(
            width: double.infinity,
            height: 51.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10.r),
              border: hasError
                  ? Border.all(color: AppColors.error, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCategory?.label ?? 'Выберите категорию',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: _selectedCategory != null
                          ? AppColors.textPrimaryLight
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondaryLight,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            _categoryError!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Дата',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
            children: [
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
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            height: 51.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('dd.MM.yyyy').format(_selectedDate),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Описание проведенных работ...',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фотографии',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            ..._existingPhotoUrls.asMap().entries.map(
                  (entry) => _buildNetworkPhotoThumbnail(
                    entry.value,
                    index: entry.key,
                    onRemove: () =>
                        setState(() => _existingPhotoUrls.removeAt(entry.key)),
                  ),
                ),
            ..._newPhotoPaths.asMap().entries.map(
                  (entry) => _buildFilePhotoThumbnail(
                    entry.value,
                    onRemove: () =>
                        setState(() => _newPhotoPaths.removeAt(entry.key)),
                  ),
                ),
            _buildAddPhotoButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkPhotoThumbnail(
    String url, {
    required int index,
    VoidCallback? onRemove,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => PhotoViewerPage.open(
            context,
            photoUrls: _existingPhotoUrls,
            initialIndex: index,
          ),
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 4.h,
            left: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilePhotoThumbnail(String path, {VoidCallback? onRemove}) {
    return Stack(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 4.h,
            left: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.add_a_photo_outlined,
          color: AppColors.textSecondaryLight,
          size: 28.sp,
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path != null) {
      setState(() => _newPhotoPaths.add(path));
    }
  }

  Future<void> _selectCategory() async {
    final result = await showModalBottomSheet<ServiceCategory>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => _CategorySelector(
        selectedCategory: _selectedCategory,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
        _categoryError = null;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onSave(BuildContext blocContext) {
    setState(() {
      _titleError = null;
      _categoryError = null;
      _mileageError = null;
    });

    bool hasError = false;

    if (_titleController.text.trim().isEmpty) {
      _titleError = 'Введите название записи';
      hasError = true;
    }

    if (_selectedCategory == null) {
      _categoryError = 'Выберите категорию';
      hasError = true;
    }

    final mileageText = _mileageController.text.trim();
    if (mileageText.isEmpty) {
      _mileageError = 'Введите пробег';
      hasError = true;
    } else {
      final mileage = int.tryParse(mileageText);
      if (mileage == null || mileage < 0) {
        _mileageError = 'Введите корректный пробег';
        hasError = true;
      }
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    final cost = _costController.text.trim().isNotEmpty
        ? double.tryParse(_costController.text.trim())
        : null;

    final updatedRecord = ServiceRecordEntity(
      id: widget.record.id,
      carId: widget.record.carId,
      userId: widget.record.userId,
      category: _selectedCategory!,
      title: _titleController.text.trim(),
      date: _selectedDate,
      mileage: int.parse(_mileageController.text.trim()),
      cost: cost,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      serviceStation: _serviceStationController.text.trim().isNotEmpty
          ? _serviceStationController.text.trim()
          : null,
      photoUrls: _existingPhotoUrls,
      createdAt: widget.record.createdAt,
      updatedAt: DateTime.now(),
    );

    blocContext.read<ServiceRecordsBloc>().add(
          ServiceRecordsUpdateRequested(
            record: updatedRecord,
            newPhotoPaths: _newPhotoPaths,
          ),
        );
  }
}

class _CategorySelector extends StatelessWidget {
  final ServiceCategory? selectedCategory;

  const _CategorySelector({this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
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
          SizedBox(height: 24.h),
          Text(
            'Выберите категорию',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ServiceCategory.values.length,
              itemBuilder: (context, index) {
                final category = ServiceCategory.values[index];
                final isSelected = category == selectedCategory;

                return ListTile(
                  leading: Icon(
                    category.icon,
                    size: 24.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  title: Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 24.sp,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, category),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../app/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/garage_bloc.dart';
import '../widgets/car_brand_selector.dart';
import '../widgets/car_model_selector.dart';
import '../widgets/year_selector.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  String? _selectedBrand;
  String? _selectedModel;
  int? _selectedYear;
  BodyType _selectedBodyType = BodyType.sedan;
  final _licensePlateController = TextEditingController();

  final List<String> _carPhotos = [];
  String? _ptsPhoto;
  String? _stsPhoto;
  String? _insurancePhoto;

  final _vinController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _brandError;
  String? _modelError;
  String? _yearError;
  String? _licensePlateError;

  bool _isLoading = false;

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GarageBloc, GarageState>(
      listener: (context, state) {
        if (state is GarageLoaded && _isLoading) {
          setState(() {
            _isLoading = false;
            _currentStep = 3;
          });
        } else if (state is GarageError && _isLoading) {
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
              const CustomAppBar(title: 'Новый автомобиль'),
              _buildProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildCurrentStep(),
                ),
              ),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              height: 4.h,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8.w : 0),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildSuccessStep();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildSelectorField(
          label: 'Марка авто',
          value: _selectedBrand,
          placeholder: 'Выберите марку',
          error: _brandError,
          onTap: _selectBrand,
        ),
        SizedBox(height: 16.h),
        _buildSelectorField(
          label: 'Модель',
          value: _selectedModel,
          placeholder: 'Выберите модель',
          error: _modelError,
          onTap: _selectedBrand != null ? _selectModel : null,
        ),
        SizedBox(height: 16.h),
        _buildSelectorField(
          label: 'Год выпуска',
          value: _selectedYear?.toString(),
          placeholder: 'Выберите год выпуска',
          error: _yearError,
          onTap: _selectYear,
        ),
        SizedBox(height: 16.h),
        _buildBodyTypeSelector(),
        SizedBox(height: 16.h),
        AuthTextField(
          controller: _licensePlateController,
          label: 'Гос. номер',
          hint: 'A000AA000',
          errorText: _licensePlateError,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_licensePlateError != null) {
              setState(() => _licensePlateError = null);
            }
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          'Добавьте фотографии автомобиля',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Добавьте фото вашего автомобиля — так его будет проще узнавать.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 16.h),
        _buildPhotoGrid(_carPhotos,
            onAdd: _addCarPhoto, onRemove: _removeCarPhoto),
        SizedBox(height: 32.h),
        Text(
          'Добавьте фотографии ваших документов',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Добавьте фото СТС, ПТС или страхового полиса, все документы будут в быстром доступе на странице вашего авто. Это необязательно.\n'
          'Только вы сможете их просматривать, так что хранить их здесь полностью безопасно.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 16.h),
        _buildDocumentPhotoField('ПТС', _ptsPhoto,
            onAdd: () => _addDocumentPhoto('pts')),
        SizedBox(height: 16.h),
        _buildDocumentPhotoField('СТС', _stsPhoto,
            onAdd: () => _addDocumentPhoto('sts')),
        SizedBox(height: 16.h),
        _buildDocumentPhotoField('Страховка', _insurancePhoto,
            onAdd: () => _addDocumentPhoto('insurance')),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          'Дополнительные данные',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Вы можете добавить дополнительные данные о своем автомобиле',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          controller: _vinController,
          label: 'VIN номер',
          hint: 'JHMCM56557C404453',
          isRequired: false,
        ),
        SizedBox(height: 16.h),
        _buildDescriptionField(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              Icons.check,
              size: 64.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Автомобиль добавлен',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тип кузова',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: BodyType.values.map((type) {
            final isSelected = type == _selectedBodyType;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedBodyType = type),
                child: Container(
                  height: 51.h,
                  margin: EdgeInsets.only(
                    right: type != BodyType.values.last ? 8.w : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectorField({
    required String label,
    String? value,
    required String placeholder,
    String? error,
    VoidCallback? onTap,
  }) {
    final hasError = error != null;
    final isDisabled = onTap == null;

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
          onTap: onTap,
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
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? AppColors.textPrimaryLight
                          : (isDisabled
                              ? AppColors.disabled
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDisabled
                      ? AppColors.disabled
                      : AppColors.textSecondaryLight,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoGrid(
    List<String> photos, {
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        ...photos.asMap().entries.map((entry) => _buildPhotoThumbnail(
              entry.value,
              onRemove: () => onRemove(entry.key),
            )),
        _buildAddPhotoButton(onTap: onAdd),
      ],
    );
  }

  Widget _buildPhotoThumbnail(String photoPath, {VoidCallback? onRemove}) {
    final isLocal = !photoPath.startsWith('http');
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 80.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: isLocal
                  ? FileImage(File(photoPath))
                  : NetworkImage(photoPath) as ImageProvider,
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
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.textSecondaryLight,
          size: 32.sp,
        ),
      ),
    );
  }

  Widget _buildDocumentPhotoField(String label, String? photoPath,
      {required VoidCallback onAdd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 100.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: photoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(File(photoPath), fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.add,
                    color: AppColors.textSecondaryLight,
                    size: 32.sp,
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
            maxLines: 6,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Пару слов об автомобиле...',
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

  Widget _buildButtons() {
    if (_currentStep == 3) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: SizedBox(
          width: double.infinity,
          height: 41.h,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.garage),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Перейти в гараж',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (_currentStep == 0) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: SizedBox(
          width: double.infinity,
          height: 41.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Следующий шаг',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 41.h,
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Предыдущий шаг',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 41.h,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_currentStep == 2 ? _submitCar : _nextStep),
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
                        _currentStep == 2 ? 'Добавить авто' : 'Следующий шаг',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) {
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateStep1() {
    bool isValid = true;

    setState(() {
      _brandError = null;
      _modelError = null;
      _yearError = null;
      _licensePlateError = null;
    });

    if (_selectedBrand == null) {
      _brandError = 'Выберите марку автомобиля';
      isValid = false;
    }

    if (_selectedModel == null) {
      _modelError = 'Выберите модель автомобиля';
      isValid = false;
    }

    if (_selectedYear == null) {
      _yearError = 'Выберите год выпуска';
      isValid = false;
    }

    if (_licensePlateController.text.trim().isEmpty) {
      _licensePlateError = 'Введите гос. номер';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _submitCar() {
    setState(() => _isLoading = true);

    context.read<GarageBloc>().add(GarageAddCar(
          brand: _selectedBrand!,
          model: _selectedModel!,
          year: _selectedYear!,
          licensePlate: _licensePlateController.text.trim(),
          mileage: 0,
          fuelType: FuelType.petrol,
          bodyType: _selectedBodyType,
          vin: _vinController.text.trim().isNotEmpty
              ? _vinController.text.trim()
              : null,
          photoPath: _carPhotos.isNotEmpty ? _carPhotos.first : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        ));
  }

  Future<void> _selectBrand() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const CarBrandSelector(),
    );

    if (result != null) {
      setState(() {
        _selectedBrand = result;
        _selectedModel = null;
        _brandError = null;
      });
    }
  }

  Future<void> _selectModel() async {
    if (_selectedBrand == null) return;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => CarModelSelector(brand: _selectedBrand!),
    );

    if (result != null) {
      setState(() {
        _selectedModel = result;
        _modelError = null;
      });
    }
  }

  Future<void> _selectYear() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const YearSelector(),
    );

    if (result != null) {
      setState(() {
        _selectedYear = result;
        _yearError = null;
      });
    }
  }

  Future<void> _addCarPhoto() async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path != null) {
      setState(() => _carPhotos.add(path));
    }
  }

  void _removeCarPhoto(int index) {
    setState(() {
      _carPhotos.removeAt(index);
    });
  }

  Future<void> _addDocumentPhoto(String type) async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path != null) {
      setState(() {
        switch (type) {
          case 'pts':
            _ptsPhoto = path;
          case 'sts':
            _stsPhoto = path;
          case 'insurance':
            _insurancePhoto = path;
        }
      });
    }
  }
}

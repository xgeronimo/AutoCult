import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/license_plate_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/garage_bloc.dart';
import '../widgets/car_brand_selector.dart';
import '../widgets/year_selector.dart';
import '../widgets/car_model_selector.dart';

class EditCarPage extends StatefulWidget {
  final CarEntity car;

  const EditCarPage({super.key, required this.car});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  late String? _selectedBrand;
  late String? _selectedModel;
  late int? _selectedYear;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _vinController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _mileageController;
  late FuelType _selectedFuelType;
  late TransmissionType? _selectedTransmission;
  late BodyType _selectedBodyType;
  late final TextEditingController _engineVolumeController;

  String? _brandError;
  String? _modelError;
  String? _yearError;
  String? _licensePlateError;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.car.brand;
    _selectedModel = widget.car.model;
    _selectedYear = widget.car.year;
    _licensePlateController =
        TextEditingController(text: widget.car.licensePlate ?? '');
    _vinController = TextEditingController(text: widget.car.vin ?? '');
    _descriptionController =
        TextEditingController(text: widget.car.description ?? '');
    _mileageController =
        TextEditingController(text: widget.car.mileage.toString());
    _selectedFuelType = widget.car.fuelType;
    _selectedTransmission = widget.car.transmission;
    _selectedBodyType = widget.car.bodyType;
    _engineVolumeController = TextEditingController(
      text: widget.car.engineVolume?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _engineVolumeController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GarageBloc, GarageState>(
      listener: (context, state) {
        if (state is GarageLoaded && _isLoading) {
          setState(() => _isLoading = false);
          AppSnackBar.show(context,
              message: 'Изменения сохранены', type: SnackBarType.success);
          context.pop();
        } else if (state is GarageError && _isLoading) {
          setState(() => _isLoading = false);
          AppSnackBar.show(context,
              message: state.message, type: SnackBarType.error);
        }
      },
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _hasChanges) {
            _showDiscardDialog();
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
                    child: _buildForm(),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildPhotoSection(),
        SizedBox(height: 24.h),
        _buildSectionTitle('Основная информация'),
        SizedBox(height: 16.h),
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
        AuthTextField(
          controller: _licensePlateController,
          label: 'Гос. номер',
          hint: 'А123АА12',
          errorText: _licensePlateError,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [LicensePlateFormatter()],
          onChanged: (_) {
            _markChanged();
            if (_licensePlateError != null) {
              setState(() => _licensePlateError = null);
            }
          },
        ),
        SizedBox(height: 16.h),
        _buildBodyTypeSelector(),
        SizedBox(height: 24.h),
        _buildSectionTitle('Характеристики'),
        SizedBox(height: 16.h),
        AuthTextField(
          controller: _mileageController,
          label: 'Пробег (км)',
          hint: '0',
          isRequired: false,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _markChanged(),
        ),
        SizedBox(height: 16.h),
        _buildFuelTypeSelector(),
        SizedBox(height: 16.h),
        AuthTextField(
          controller: _engineVolumeController,
          label: 'Объём двигателя (л)',
          hint: '2.0',
          isRequired: false,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          onChanged: (_) => _markChanged(),
        ),
        SizedBox(height: 16.h),
        _buildTransmissionSelector(),
        SizedBox(height: 24.h),
        _buildSectionTitle('Дополнительно'),
        SizedBox(height: 16.h),
        AuthTextField(
          controller: _vinController,
          label: 'VIN номер',
          hint: 'JHMCM56557C404453',
          isRequired: false,
          onChanged: (_) => _markChanged(),
        ),
        SizedBox(height: 16.h),
        _buildDescriptionField(),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return BlocBuilder<GarageBloc, GarageState>(
      buildWhen: (prev, curr) {
        if (curr is GarageLoaded) {
          return curr.cars.any((c) => c.id == widget.car.id);
        }
        return false;
      },
      builder: (context, state) {
        final currentCar = state is GarageLoaded
            ? state.cars.where((c) => c.id == widget.car.id).firstOrNull ??
                widget.car
            : widget.car;
        final hasPhoto =
            currentCar.photoUrl != null && currentCar.photoUrl!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Фото автомобиля',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _changePhoto,
              child: Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasPhoto)
                      Image.network(
                        currentCar.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                      )
                    else
                      _buildPhotoPlaceholder(),
                    Positioned(
                      bottom: 12.h,
                      right: 12.w,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasPhoto)
                            GestureDetector(
                              onTap: () => _showDeletePhotoDialog(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          if (hasPhoto) SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: _changePhoto,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      color: Colors.white, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    hasPhoto ? 'Изменить' : 'Добавить фото',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Image.asset(
        _selectedBodyType.imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  void _showDeletePhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Удалить фото?',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Фото автомобиля будет удалено без возможности восстановления.',
          style:
              TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GarageBloc>().add(
                    GarageDeleteCarPhoto(carId: widget.car.id),
                  );
            },
            child: Text(
              'Удалить',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoto() async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path != null && mounted) {
      context.read<GarageBloc>().add(
            GarageUpdateCarPhoto(carId: widget.car.id, photoPath: path),
          );
      _markChanged();
    }
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
                onTap: () {
                  setState(() => _selectedBodyType = type);
                  _markChanged();
                },
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
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
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildFuelTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тип топлива',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: FuelType.values.map((type) {
            final isSelected = type == _selectedFuelType;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFuelType = type);
                _markChanged();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransmissionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Трансмиссия',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: TransmissionType.values.map((type) {
            final isSelected = type == _selectedTransmission;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTransmission = type);
                _markChanged();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
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
            maxLines: 5,
            onChanged: (_) => _markChanged(),
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

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: SizedBox(
        width: double.infinity,
        height: 41.h,
        child: ElevatedButton(
          onPressed: _isLoading || !_hasChanges ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.divider,
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
                  'Сохранить изменения',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  bool _validate() {
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
    final plateText = _licensePlateController.text.trim();
    if (plateText.isEmpty) {
      _licensePlateError = 'Введите гос. номер';
      isValid = false;
    } else {
      final plateError = Validators.licensePlate(plateText);
      if (plateError != null) {
        _licensePlateError = plateError;
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  void _save() {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final mileage =
        int.tryParse(_mileageController.text.trim()) ?? widget.car.mileage;
    final engineVolume = double.tryParse(_engineVolumeController.text.trim());

    final garageState = context.read<GarageBloc>().state;
    final currentCar = garageState is GarageLoaded
        ? garageState.cars.where((c) => c.id == widget.car.id).firstOrNull ??
            widget.car
        : widget.car;

    final updatedCar = currentCar.copyWith(
      brand: _selectedBrand!,
      model: _selectedModel!,
      year: _selectedYear!,
      vin: () => _vinController.text.trim().isNotEmpty
          ? _vinController.text.trim()
          : null,
      licensePlate: () => _licensePlateController.text.trim(),
      mileage: mileage,
      fuelType: _selectedFuelType,
      engineVolume: () => engineVolume,
      transmission: () => _selectedTransmission,
      bodyType: _selectedBodyType,
      description: () => _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      updatedAt: DateTime.now(),
    );

    context.read<GarageBloc>().add(GarageUpdateCar(car: updatedCar));
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Отменить изменения?',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Несохранённые изменения будут потеряны.',
          style:
              TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Остаться',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(
              'Отменить',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
    if (result != null && result != _selectedBrand) {
      setState(() {
        _selectedBrand = result;
        _selectedModel = null;
        _brandError = null;
      });
      _markChanged();
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
      _markChanged();
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
      _markChanged();
    }
  }
}

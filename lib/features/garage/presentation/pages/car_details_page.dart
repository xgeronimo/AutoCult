import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/photo_viewer_page.dart';
import '../../../../app/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../documents/presentation/bloc/documents_bloc.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/garage_bloc.dart';
import '../../../expenses/presentation/bloc/expenses_bloc.dart';
import '../../../service_records/domain/entities/service_record_entity.dart';
import '../../../service_records/presentation/bloc/service_records_bloc.dart';

class CarDetailsPage extends StatelessWidget {
  final CarEntity car;

  const CarDetailsPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ServiceRecordsBloc>()
            ..add(ServiceRecordsLoadRequested(car.id)),
        ),
        BlocProvider(
          create: (_) =>
              sl<DocumentsBloc>()..add(DocumentsLoadRequested(car.id)),
        ),
        BlocProvider(
          create: (_) => sl<ExpensesBloc>()..add(ExpensesLoadRequested(car.id)),
        ),
      ],
      child: _CarDetailsView(car: car),
    );
  }
}

class _CarDetailsView extends StatelessWidget {
  final CarEntity car;

  const _CarDetailsView({required this.car});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      buildWhen: (prev, curr) {
        if (curr is GarageLoaded) {
          return curr.cars.any((c) => c.id == car.id);
        }
        return false;
      },
      builder: (context, garageState) {
        final currentCar = garageState is GarageLoaded
            ? garageState.cars.where((c) => c.id == car.id).firstOrNull ?? car
            : car;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(context, currentCar),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCarPhoto(context, currentCar),
                        _buildCarInfoSection(currentCar),
                        SizedBox(height: 16.h),
                        _buildSpecsRow(currentCar),
                        SizedBox(height: 16.h),
                        if (currentCar.isFormer) _buildFormerBadge(),
                        if (currentCar.isFormer) SizedBox(height: 16.h),
                        _buildExpensesCard(context, currentCar),
                        SizedBox(height: 16.h),
                        _buildDocumentsSection(context),
                        SizedBox(height: 24.h),
                        _buildServiceHistorySection(context, currentCar),
                        SizedBox(height: 16.h),
                        _buildActionsSection(context, currentCar),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, CarEntity car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          GlassPillButton(
            iconPath: 'assets/icons/arrow-left-s-line.svg',
            onTap: () => context.pop(),
          ),
          Expanded(
            child: Text(
              car.fullName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GlassPillButton(
            iconPath: 'assets/icons/edit-line.svg',
            onTap: () => context.push(
              AppRoutes.editCar.replaceAll(':carId', car.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarPhoto(BuildContext context, CarEntity car) {
    final hasNetworkPhoto = car.photoUrl != null && car.photoUrl!.isNotEmpty;
    return GestureDetector(
      onTap: hasNetworkPhoto
          ? () => PhotoViewerPage.open(
                context,
                photoUrls: [car.photoUrl!],
              )
          : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasNetworkPhoto
            ? Image.network(
                car.photoUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(car),
              )
            : _buildPhotoPlaceholder(car),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(CarEntity car) {
    return Image.asset(
      car.bodyType.imagePath,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _buildCarInfoSection(CarEntity car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            car.fullName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            car.shortDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (car.licensePlate != null && car.licensePlate!.isNotEmpty)
                _buildInfoChip(car.licensePlate!),
              if (car.vin != null && car.vin!.isNotEmpty)
                _buildInfoChip('VIN: ${car.vin}'),
              _buildInfoChip(
                  '${NumberFormat('#,###', 'ru_RU').format(car.mileage)} км'),
            ],
          ),
          if (car.description != null && car.description!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              car.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildSpecsRow(CarEntity car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          if (car.engineVolume != null)
            _buildSpecItem(
              Icons.speed_rounded,
              '${car.engineVolume!.toStringAsFixed(1)} л',
            ),
          if (car.engineVolume != null && car.transmission != null)
            SizedBox(width: 12.w),
          if (car.transmission != null)
            _buildSpecItem(
              Icons.settings_rounded,
              car.transmission!.label,
            ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormerBadge() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Автомобиль отмечен как бывший. Создание новых записей недоступно.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesCard(BuildContext context, CarEntity car) {
    return BlocBuilder<ExpensesBloc, ExpensesState>(
      builder: (context, state) {
        double monthTotal = 0;
        if (state is ExpensesLoaded) {
          final now = DateTime.now();
          monthTotal = state.expenses
              .where(
                  (e) => e.date.year == now.year && e.date.month == now.month)
              .fold(0.0, (sum, e) => sum + e.amount);
        }

        return GestureDetector(
          onTap: () => context.push(
            AppRoutes.expenses.replaceAll(':carId', car.id),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Расходы и статистика',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (state is ExpensesLoaded)
                        Text(
                          'В этом месяце: ${NumberFormat('#,###', 'ru_RU').format(monthTotal.toInt())} ₽',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: monthTotal > 0
                                ? AppColors.primary
                                : AppColors.textSecondaryLight,
                          ),
                        )
                      else
                        Text(
                          'Журнал учёта регулярных расходов',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/arrow-right-s-line.svg',
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.textSecondaryLight,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return BlocBuilder<DocumentsBloc, DocumentsState>(
      builder: (context, state) {
        final documents =
            state is DocumentsLoaded ? state.documents : <DocumentEntity>[];

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Документы',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                child: state is DocumentsLoading
                    ? Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : documents.isEmpty
                        ? Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 44.h,
                              child: ElevatedButton(
                                onPressed: () => _showAddDocumentSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Добавить документ',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...documents.map((doc) => Padding(
                                      padding: EdgeInsets.only(right: 12.w),
                                      child: _buildDocumentItem(
                                        context,
                                        doc,
                                        onLongPress: () =>
                                            _showDeleteDocDialog(context, doc),
                                      ),
                                    )),
                                _buildAddDocumentItem(context),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    DocumentEntity doc, {
    VoidCallback? onLongPress,
  }) {
    final hasPhoto = doc.photoUrl.isNotEmpty;
    return GestureDetector(
      onTap: hasPhoto ? () => _showDocumentPhoto(context, doc) : null,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.network(
                    doc.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: SvgPicture.asset(
                        'assets/icons/file-list-3-fill.svg',
                        width: 28.w,
                        height: 28.w,
                        colorFilter: ColorFilter.mode(
                          AppColors.textSecondaryLight,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: SvgPicture.asset(
                      'assets/icons/file-list-3-fill.svg',
                      width: 28.w,
                      height: 28.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.textSecondaryLight,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 64.w,
            child: Text(
              doc.displayName,
              style:
                  TextStyle(fontSize: 12.sp, color: AppColors.textPrimaryLight),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDocumentItem(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddDocumentSheet(context),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/add-line.svg',
                width: 28.w,
                height: 28.w,
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondaryLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 64.w,
            child: Text(
              ' ',
              style: TextStyle(fontSize: 12.sp),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentSheet(BuildContext context) {
    showModalBottomSheet(
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
                'Выберите тип документа',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),
              ...DocumentType.values.map(
                (type) => ListTile(
                  title: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndAddDocument(context, type);
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAddDocument(
      BuildContext context, DocumentType type) async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path == null || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<DocumentsBloc>().add(
          DocumentsAddRequested(
            carId: car.id,
            userId: authState.user.id,
            type: type,
            photoPath: path,
          ),
        );
  }

  void _showDocumentPhoto(BuildContext context, DocumentEntity doc) {
    if (doc.photoUrl.isEmpty) return;
    PhotoViewerPage.open(
      context,
      photoUrls: [doc.photoUrl],
    );
  }

  void _showDeleteDocDialog(BuildContext context, DocumentEntity doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Удалить документ?',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${doc.displayName} будет удалён без возможности восстановления.',
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
              context.read<DocumentsBloc>().add(
                    DocumentsDeleteRequested(doc.id),
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

  Widget _buildServiceHistorySection(BuildContext context, CarEntity car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'История обслуживания',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          if (!car.isFormer) ...[
            _buildAddRecordCard(context, car),
            SizedBox(height: 12.h),
          ],
          BlocBuilder<ServiceRecordsBloc, ServiceRecordsState>(
            builder: (context, state) {
              if (state is ServiceRecordsLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              if (state is ServiceRecordsError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            size: 40.sp, color: AppColors.error),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is ServiceRecordsLoaded) {
                if (state.records.isEmpty) {
                  return _buildEmptyRecords();
                }
                return Column(
                  children: state.records
                      .map((record) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child:
                                _buildServiceRecordCard(context, record, car),
                          ))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecords() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Column(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 48.sp,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              'Записей об обслуживании пока нет',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Добавьте первую запись, чтобы начать\nвести историю обслуживания',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddRecordCard(BuildContext context, CarEntity car) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.addServiceRecord.replaceAll(':carId', car.id),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Добавить новую запись',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow-right-s-line.svg',
              width: 24.w,
              height: 24.w,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRecordCard(
    BuildContext context,
    ServiceRecordEntity record,
    CarEntity car,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.serviceRecordDetails
            .replaceAll(':carId', car.id)
            .replaceAll(':recordId', record.id),
      ),
      onLongPress: () => _showRecordOptionsSheet(context, record, car),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  record.category.icon,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          record.category.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Text(
                        dateFormat.format(record.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###', 'ru_RU').format(record.mileage)} км',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (record.cost != null)
              Text(
                '${NumberFormat('#,###', 'ru_RU').format(record.cost!.toInt())} ₽',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, CarEntity car) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 16.h),
          _buildActionTile(
            context,
            icon: Icons.description_outlined,
            label: 'Сформировать отчёт',
            subtitle: 'PDF с историей обслуживания и расходами',
            onTap: () => _showGenerateReportDialog(context, car),
          ),
          SizedBox(height: 8.h),
          if (!car.isFormer)
            _buildActionTile(
              context,
              icon: Icons.archive_outlined,
              label: 'Отметить как бывший',
              subtitle:
                  'Вы сможете просматривать историю, но не создавать записи',
              onTap: () => _showMarkAsFormerDialog(context, car),
            ),
          if (!car.isFormer) SizedBox(height: 8.h),
          _buildActionTile(
            context,
            icon: Icons.delete_outline_rounded,
            label: 'Удалить автомобиль',
            subtitle: 'Все данные будут безвозвратно удалены',
            isDestructive: true,
            onTap: () => _showDeleteCarDialog(context, car),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.05)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDestructive
                          ? AppColors.error.withValues(alpha: 0.7)
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordOptionsSheet(
    BuildContext context,
    ServiceRecordEntity record,
    CarEntity car,
  ) {
    showModalBottomSheet(
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
                record.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 20.h),
              _buildSheetOption(
                icon: Icons.visibility_outlined,
                label: 'Просмотреть',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    AppRoutes.serviceRecordDetails
                        .replaceAll(':carId', car.id)
                        .replaceAll(':recordId', record.id),
                  );
                },
              ),
              _buildSheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Удалить',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteRecordDialog(context, record, car);
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimaryLight;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  void _showDeleteRecordDialog(
    BuildContext context,
    ServiceRecordEntity record,
    CarEntity car,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Удалить запись?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Запись "${record.title}" будет удалена без возможности восстановления.',
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
              context.read<ServiceRecordsBloc>().add(
                    ServiceRecordsDeleteRequested(
                      recordId: record.id,
                      carId: car.id,
                    ),
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

  void _showMarkAsFormerDialog(BuildContext context, CarEntity car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Отметить как бывший?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Вся история обслуживания сохранится, но вы не сможете создавать новые записи и вести учёт расходов для этого автомобиля.',
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
                    GarageMarkAsFormer(carId: car.id),
                  );
            },
            child: Text(
              'Подтвердить',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCarDialog(BuildContext context, CarEntity car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Удалить автомобиль?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Автомобиль "${car.fullName}" и все связанные с ним данные (записи обслуживания, расходы, документы) будут удалены без возможности восстановления.',
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
                    GarageDeleteCar(carId: car.id),
                  );
              context.go(AppRoutes.home);
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

  void _showGenerateReportDialog(BuildContext context, CarEntity car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Сформировать отчёт?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Будет сформирован PDF-отчёт с историей обслуживания и расходами для "${car.fullName}".',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Формирование отчёта...'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              // TODO: Implement actual PDF generation
            },
            child: Text(
              'Сформировать',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

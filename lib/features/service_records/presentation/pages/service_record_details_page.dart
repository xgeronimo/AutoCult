import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/photo_viewer_page.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/service_record_entity.dart';
import '../bloc/service_records_bloc.dart';

class ServiceRecordDetailsPage extends StatelessWidget {
  final String carId;
  final String recordId;

  const ServiceRecordDetailsPage({
    super.key,
    required this.carId,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ServiceRecordsBloc>()..add(ServiceRecordsLoadRequested(carId)),
      child: _ServiceRecordDetailsView(carId: carId, recordId: recordId),
    );
  }
}

class _ServiceRecordDetailsView extends StatelessWidget {
  final String carId;
  final String recordId;

  const _ServiceRecordDetailsView({
    required this.carId,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ServiceRecordsBloc, ServiceRecordsState>(
          listener: (context, state) {
            if (state is ServiceRecordsLoaded &&
                !state.records.any((r) => r.id == recordId)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Запись удалена'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is ServiceRecordsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ServiceRecordsError) {
              return Column(
                children: [
                  const CustomAppBar(title: 'Запись'),
                  Expanded(
                    child: Center(
                      child: Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is ServiceRecordsLoaded) {
              final record = state.records
                  .where((r) => r.id == recordId)
                  .firstOrNull;
              if (record == null) {
                return Column(
                  children: [
                    const CustomAppBar(title: 'Запись'),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Запись не найдена',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return _buildContent(context, record);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceRecordEntity record) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'ru_RU');
    final numberFormat = NumberFormat('#,###', 'ru_RU');

    return Column(
      children: [
        _buildAppBar(context, record),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Category badge and title
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          record.category.icon,
                          style: TextStyle(fontSize: 24.sp),
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
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              record.category.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Info cards
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Дата',
                  value: dateFormat.format(record.date),
                ),
                SizedBox(height: 12.h),

                _buildInfoRow(
                  icon: Icons.speed_rounded,
                  label: 'Пробег',
                  value: '${numberFormat.format(record.mileage)} км',
                ),
                SizedBox(height: 12.h),

                if (record.cost != null) ...[
                  _buildInfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Стоимость',
                    value: '${numberFormat.format(record.cost!.toInt())} ₽',
                    valueColor: AppColors.primary,
                  ),
                  SizedBox(height: 12.h),
                ],

                if (record.serviceStation != null &&
                    record.serviceStation!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Сервис',
                    value: record.serviceStation!,
                  ),
                  SizedBox(height: 12.h),
                ],

                if (record.description != null &&
                    record.description!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Описание',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      record.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimaryLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                if (record.hasPhotos) ...[
                  SizedBox(height: 24.h),
                  Text(
                    'Фотографии',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 120.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: record.photoUrls.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => PhotoViewerPage.open(
                            context,
                            photoUrls: record.photoUrls,
                            initialIndex: index,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              record.photoUrls[index],
                              width: 120.w,
                              height: 120.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120.w,
                                height: 120.h,
                                color: AppColors.inputBackground,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textSecondaryLight,
                                  size: 32.sp,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                SizedBox(height: 32.h),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  height: 41.h,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showDeleteDialog(context, record),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(
                      'Удалить запись',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ServiceRecordEntity record) {
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
              'Запись обслуживания',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GlassPillButton(
            iconPath: 'assets/icons/edit-line.svg',
            onTap: () async {
              await context.push(
                '/garage/$carId/records/${record.id}/edit',
                extra: record,
              );
              if (context.mounted) {
                context
                    .read<ServiceRecordsBloc>()
                    .add(ServiceRecordsLoadRequested(carId));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondaryLight),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ServiceRecordEntity record,
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Запись "${record.title}" будет удалена без возможности восстановления.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
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
                      carId: carId,
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
}

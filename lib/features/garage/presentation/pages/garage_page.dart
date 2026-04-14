import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../app/router/app_router.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/garage_bloc.dart';
import '../widgets/garage_car_card.dart';
import '../widgets/empty_garage_card.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final navBarHeight = LiquidGlassNavBar.totalHeight(context);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, top: 10.h, bottom: 16.h),
            child: Text(
              'Гараж',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<GarageBloc, GarageState>(
              builder: (context, state) {
                if (state is GarageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GarageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48.sp, color: AppColors.error),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondaryLight),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context
                              .read<GarageBloc>()
                              .add(const GarageLoadCars()),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }
                final cars = state is GarageLoaded ? state.cars : <CarEntity>[];
                return _buildContent(cars, navBarHeight);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<CarEntity> cars, double navBarHeight) {
    final activeCars = cars.where((c) => !c.isFormer).toList();
    final formerCars = cars.where((c) => c.isFormer).toList();

    if (cars.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            const EmptyGarageCard(),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.addCar),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Добавить автомобиль',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: navBarHeight + 24.h,
      ),
      children: [
        ...activeCars.map((car) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GarageCarCard(
                car: car,
                onTap: () => context
                    .push(AppRoutes.carDetails.replaceAll(':carId', car.id)),
              ),
            )),
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 41.h,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.addCar),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Добавить автомобиль',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        if (formerCars.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'Бывшие',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
              ],
            ),
          ),
          ...formerCars.map((car) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GarageCarCard(
                  car: car,
                  onTap: () => context
                      .push(AppRoutes.carDetails.replaceAll(':carId', car.id)),
                ),
              )),
        ],
      ],
    );
  }
}

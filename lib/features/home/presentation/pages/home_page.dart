import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../app/router/app_router.dart';
import '../../../garage/domain/entities/car_entity.dart';
import '../../../garage/presentation/bloc/garage_bloc.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../widgets/car_carousel_card.dart';
import '../widgets/expense_category_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int _currentCarIndex = 0;
  final PageController _carPageController =
      PageController(viewportFraction: 0.85);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _carPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, garageState) {
        final cars =
            garageState is GarageLoaded ? garageState.cars : <CarEntity>[];

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      _buildCarCarousel(cars),
                      SizedBox(height: 5.h),
                      _buildPageIndicator(cars),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45.h,
                          child: ElevatedButton(
                            onPressed: cars.isNotEmpty
                                ? () => _navigateToAddServiceRecord(cars)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Добавить запись об обслуживании',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildExpensesGrid(cars),
                      SizedBox(height: 16.h),
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

  Widget _buildHeader() {
    return Padding(
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 10.h),
      child: Row(
        children: [
          Text(
            'Главная',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final unreadCount =
                  state is NotificationsLoaded ? state.unreadCount : 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassPillButton(
                    iconPath: 'assets/icons/notification-4-line.svg',
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.w,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(width: 8.w),
          GlassPillButton(
            iconPath: 'assets/icons/user-line.svg',
            onTap: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCarousel(List<CarEntity> cars) {
    if (cars.isEmpty) {
      return SizedBox(
        height: 229.h,
        child: AddCarCard(
          onTap: () => context.push(AppRoutes.addCar),
        ),
      );
    }

    return SizedBox(
      height: 229.h,
      child: PageView.builder(
        controller: _carPageController,
        itemCount: cars.length,
        onPageChanged: (index) {
          setState(() => _currentCarIndex = index);
          context
              .read<GarageBloc>()
              .add(GarageSelectCar(carId: cars[index].id));
        },
        itemBuilder: (context, index) {
          final car = cars[index];
          return CarCarouselCard(
            car: car,
            onTap: () {
              context.push(AppRoutes.carDetails.replaceAll(':carId', car.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(List<CarEntity> cars) {
    if (cars.length <= 1) return const SizedBox.shrink();
    final itemCount = cars.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == _currentCarIndex;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textPrimaryLight : AppColors.divider,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildExpensesGrid(List<CarEntity> cars) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 7.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 164 / 64,
        ),
        itemCount: ExpenseCategory.values.length,
        itemBuilder: (context, index) {
          final category = ExpenseCategory.values[index];
          return ExpenseCategoryCard(
            category: category,
            onTap: () => _navigateToAddExpense(category, cars),
          );
        },
      ),
    );
  }

  void _navigateToAddServiceRecord(List<CarEntity> cars) {
    if (cars.isEmpty) return;
    final currentCar =
        _currentCarIndex < cars.length ? cars[_currentCarIndex] : cars.first;
    context
        .push(AppRoutes.addServiceRecord.replaceAll(':carId', currentCar.id));
  }

  void _navigateToAddExpense(ExpenseCategory category, List<CarEntity> cars) {
    if (cars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала добавьте автомобиль')),
      );
      return;
    }
    final currentCar =
        _currentCarIndex < cars.length ? cars[_currentCarIndex] : cars.first;
    context.push(
      '${AppRoutes.addExpense.replaceAll(':carId', currentCar.id)}?category=${category.name}',
    );
  }
}

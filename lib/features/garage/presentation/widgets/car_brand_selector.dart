import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Селектор марки автомобиля
class CarBrandSelector extends StatefulWidget {
  const CarBrandSelector({super.key});

  @override
  State<CarBrandSelector> createState() => _CarBrandSelectorState();
}

class _CarBrandSelectorState extends State<CarBrandSelector> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _brands = [
    'Audi',
    'BMW',
    'Chevrolet',
    'Citroen',
    'Dacia',
    'Fiat',
    'Ford',
    'Honda',
    'Hyundai',
    'Infiniti',
    'Jaguar',
    'Jeep',
    'Kia',
    'Lada',
    'Land Rover',
    'Lexus',
    'Mazda',
    'Mercedes-Benz',
    'Mini',
    'Mitsubishi',
    'Nissan',
    'Opel',
    'Peugeot',
    'Porsche',
    'Renault',
    'Seat',
    'Skoda',
    'Subaru',
    'Suzuki',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo',
  ];

  List<String> get _filteredBrands {
    if (_searchQuery.isEmpty) return _brands;
    return _brands
        .where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Заголовок
              Text(
                'Выберите марку',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),

              // Поиск
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск марки',
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondaryLight,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Список марок
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredBrands.length,
                  itemBuilder: (context, index) {
                    final brand = _filteredBrands[index];
                    return ListTile(
                      title: Text(
                        brand,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, brand),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

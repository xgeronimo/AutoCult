import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CarModelSelector extends StatelessWidget {
  final String brand;

  const CarModelSelector({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final models = _getModelsForBrand(brand);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
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
                'Выберите модель',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    return ListTile(
                      title: Text(
                        model,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, model),
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

  List<String> _getModelsForBrand(String brand) {
    final models = <String, List<String>>{
      'Audi': ['A1', 'A3', 'A3 Sportback', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q3', 'Q5', 'Q7', 'Q8', 'TT', 'R8'],
      'BMW': ['1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '6 Series', '7 Series', '8 Series', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7'],
      'Mercedes-Benz': ['A-Class', 'B-Class', 'C-Class', 'E-Class', 'S-Class', 'CLA', 'CLS', 'GLA', 'GLB', 'GLC', 'GLE', 'GLS'],
      'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Touareg', 'Polo', 'Jetta', 'Arteon', 'ID.4', 'T-Roc', 'T-Cross'],
      'Toyota': ['Camry', 'Corolla', 'RAV4', 'Land Cruiser', 'Prius', 'Yaris', 'Highlander', 'C-HR', 'Supra'],
      'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Pilot', 'Fit', 'Odyssey'],
      'Mazda': ['3', '6', 'CX-3', 'CX-5', 'CX-9', 'MX-5', 'CX-30'],
      'Hyundai': ['Solaris', 'Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Creta', 'Kona', 'Palisade'],
      'Kia': ['Rio', 'Cerato', 'Optima', 'Sportage', 'Sorento', 'Seltos', 'Soul', 'Stinger'],
      'Nissan': ['Qashqai', 'X-Trail', 'Juke', 'Murano', 'Pathfinder', 'Leaf', 'Note', 'Sentra'],
    };

    return models[brand] ?? ['Другая модель'];
  }
}

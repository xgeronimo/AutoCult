import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CarModelSelector extends StatefulWidget {
  final String brand;

  const CarModelSelector({super.key, required this.brand});

  @override
  State<CarModelSelector> createState() => _CarModelSelectorState();
}

class _CarModelSelectorState extends State<CarModelSelector> {
  bool _isCustomInput = false;
  final _customModelController = TextEditingController();
  String? _customModelError;

  @override
  void dispose() {
    _customModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final models = _getModelsForBrand(widget.brand);

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
              if (_isCustomInput)
                _buildCustomInput()
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: models.length + 1,
                    itemBuilder: (context, index) {
                      if (index == models.length) {
                        return ListTile(
                          title: Text(
                            'Другая',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          onTap: () {
                            setState(() => _isCustomInput = true);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        );
                      }
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

  Widget _buildCustomInput() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          TextField(
            controller: _customModelController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Введите название модели',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => _submitCustomModel(),
          ),
          if (_customModelError != null) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _customModelError!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 41.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCustomInput = false;
                        _customModelError = null;
                        _customModelController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inputBackground,
                      foregroundColor: AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Назад',
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
                    onPressed: _submitCustomModel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Подтвердить',
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
        ],
      ),
    );
  }

  void _submitCustomModel() {
    final text = _customModelController.text.trim();
    if (text.isEmpty) {
      setState(() => _customModelError = 'Введите название модели');
      return;
    }
    Navigator.pop(context, text);
  }

  List<String> _getModelsForBrand(String brand) {
    final models = <String, List<String>>{
      'Audi': [
        'A1',
        'A3',
        'A3 Sportback',
        'A4',
        'A5',
        'A6',
        'A7',
        'A8',
        'Q3',
        'Q5',
        'Q7',
        'Q8',
        'TT',
        'R8'
      ],
      'BMW': [
        '1 Series',
        '2 Series',
        '3 Series',
        '4 Series',
        '5 Series',
        '6 Series',
        '7 Series',
        '8 Series',
        'X1',
        'X2',
        'X3',
        'X4',
        'X5',
        'X6',
        'X7'
      ],
      'Mercedes-Benz': [
        'A-Class',
        'B-Class',
        'C-Class',
        'E-Class',
        'S-Class',
        'CLA',
        'CLS',
        'GLA',
        'GLB',
        'GLC',
        'GLE',
        'GLS'
      ],
      'Volkswagen': [
        'Golf',
        'Passat',
        'Tiguan',
        'Touareg',
        'Polo',
        'Jetta',
        'Arteon',
        'ID.4',
        'T-Roc',
        'T-Cross'
      ],
      'Toyota': [
        'Camry',
        'Corolla',
        'RAV4',
        'Land Cruiser',
        'Prius',
        'Yaris',
        'Highlander',
        'C-HR',
        'Supra'
      ],
      'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Pilot', 'Fit', 'Odyssey'],
      'Mazda': ['3', '6', 'CX-3', 'CX-5', 'CX-9', 'MX-5', 'CX-30'],
      'Hyundai': [
        'Solaris',
        'Elantra',
        'Sonata',
        'Tucson',
        'Santa Fe',
        'Creta',
        'Kona',
        'Palisade'
      ],
      'Kia': [
        'Rio',
        'Cerato',
        'Optima',
        'Sportage',
        'Sorento',
        'Seltos',
        'Soul',
        'Stinger'
      ],
      'Nissan': [
        'Qashqai',
        'X-Trail',
        'Juke',
        'Murano',
        'Pathfinder',
        'Leaf',
        'Note',
        'Sentra'
      ],
    };

    return models[brand] ?? [];
  }
}

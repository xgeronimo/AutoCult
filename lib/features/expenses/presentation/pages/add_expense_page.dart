import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expenses_bloc.dart';

class AddExpensePage extends StatefulWidget {
  final String carId;
  final ExpenseCategory? initialCategory;

  const AddExpensePage({
    super.key,
    required this.carId,
    this.initialCategory,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;

  String? _amountError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedCategory = widget.initialCategory ?? ExpenseCategory.fuel;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpensesBloc>(),
      child: BlocListener<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpensesAddSuccess) {
            setState(() => _isLoading = false);
            SuccessDialog.showExpenseAdded(
              context,
              onContinue: () {
                Navigator.of(context).pop();
                context.pop();
              },
            );
          } else if (state is ExpensesError) {
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
                const CustomAppBar(title: 'Добавление расходов'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        _buildCategoryIcon(),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: _selectCategory,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedCategory.label,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondaryLight,
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                        AuthTextField(
                          controller: _amountController,
                          label: 'Стоимость',
                          hint: '0 руб.',
                          errorText: _amountError,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (_amountError != null) {
                              setState(() => _amountError = null);
                            }
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildDateField(),
                        SizedBox(height: 16.h),
                        _buildNoteField(),
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
                        onPressed: _isLoading ? null : () => _onAdd(context),
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
                                'Добавить',
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

  Widget _buildCategoryIcon() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          _getCategoryIconPath(),
          width: 40.w,
          height: 40.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF09121F),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  String _getCategoryIconPath() {
    return switch (_selectedCategory) {
      ExpenseCategory.fuel => 'assets/icons/charging-pile-fill.svg',
      ExpenseCategory.parking => 'assets/icons/parking-fill.svg',
      ExpenseCategory.fines => 'assets/icons/traffic-light-fill.svg',
      ExpenseCategory.tollRoad => 'assets/icons/route-fill.svg',
      ExpenseCategory.wash => 'assets/icons/drop-fill.svg',
      ExpenseCategory.carCare => 'assets/icons/brush-fill.svg',
      ExpenseCategory.accessories => 'assets/icons/star-s-fill.svg',
      ExpenseCategory.taxes => 'assets/icons/bank-fill.svg',
      ExpenseCategory.insurance => 'assets/icons/passport-fill.svg',
      ExpenseCategory.other => 'assets/icons/bubble-chart-fill.svg',
    };
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

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Заметка',
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
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Комментарий (необязательно)',
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectCategory() async {
    final result = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => _ExpenseCategorySelector(
        selectedCategory: _selectedCategory,
      ),
    );

    if (result != null) {
      setState(() => _selectedCategory = result);
    }
  }

  void _onAdd(BuildContext blocContext) {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _amountError = 'Введите стоимость');
      return;
    }
    final amount = double.tryParse(amountText.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Введите корректную сумму');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AppSnackBar.show(context,
          message: 'Ошибка авторизации', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    blocContext.read<ExpensesBloc>().add(
          ExpensesAddRequested(
            carId: widget.carId,
            userId: authState.user.id,
            category: _selectedCategory,
            amount: amount,
            date: _selectedDate,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          ),
        );
  }
}

class _ExpenseCategorySelector extends StatelessWidget {
  final ExpenseCategory selectedCategory;

  const _ExpenseCategorySelector({required this.selectedCategory});

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
              itemCount: ExpenseCategory.values.length,
              itemBuilder: (context, index) {
                final category = ExpenseCategory.values[index];
                final isSelected = category == selectedCategory;
                return ListTile(
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
                      ? Icon(Icons.check, color: AppColors.primary, size: 24.sp)
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

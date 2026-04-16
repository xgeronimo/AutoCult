import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/services/pdf_report_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../injection_container.dart';
import '../../../garage/domain/entities/car_entity.dart';
import '../../domain/entities/service_record_entity.dart';

class ReportSelectionPage extends StatefulWidget {
  final CarEntity car;
  final List<ServiceRecordEntity> records;

  const ReportSelectionPage({
    super.key,
    required this.car,
    required this.records,
  });

  @override
  State<ReportSelectionPage> createState() => _ReportSelectionPageState();
}

class _ReportSelectionPageState extends State<ReportSelectionPage> {
  final Set<String> _selectedIds = {};
  ServiceCategory? _filterCategory;
  bool _isGenerating = false;

  late List<ServiceRecordEntity> _sortedRecords;

  @override
  void initState() {
    super.initState();
    _sortedRecords = List<ServiceRecordEntity>.from(widget.records)
      ..sort((a, b) => b.date.compareTo(a.date));
    _selectedIds.addAll(_sortedRecords.map((r) => r.id));
  }

  List<ServiceRecordEntity> get _filteredRecords {
    if (_filterCategory == null) return _sortedRecords;
    return _sortedRecords.where((r) => r.category == _filterCategory).toList();
  }

  int get _selectedCount => _selectedIds.length;

  bool get _allFilteredSelected =>
      _filteredRecords.every((r) => _selectedIds.contains(r.id));

  void _toggleRecord(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allFilteredSelected) {
        for (final r in _filteredRecords) {
          _selectedIds.remove(r.id);
        }
      } else {
        for (final r in _filteredRecords) {
          _selectedIds.add(r.id);
        }
      }
    });
  }

  Future<void> _generateReport() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final selected =
          _sortedRecords.where((r) => _selectedIds.contains(r.id)).toList();

      final pdfBytes = await sl<PdfReportService>().generateServiceReport(
        car: widget.car,
        records: selected,
      );

      if (!mounted) return;

      await _showReportActions(pdfBytes);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Ошибка при формировании отчёта: $e',
          type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _showReportActions(Uint8List pdfBytes) async {
    final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final filename =
        'Отчёт_${widget.car.brand}_${widget.car.model}_$dateStr.pdf';

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
                'Отчёт сформирован',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Выбрано записей: $_selectedCount',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 20.h),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'Предпросмотр',
                onTap: () {
                  Navigator.pop(ctx);
                  _openPreview(pdfBytes, filename);
                },
              ),
              SizedBox(height: 10.h),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Поделиться',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: filename,
                  );
                },
              ),
              SizedBox(height: 10.h),
              _buildActionButton(
                icon: Icons.print_outlined,
                label: 'Печать',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Printing.layoutPdf(
                    onLayout: (_) => pdfBytes,
                    name: filename,
                  );
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  void _openPreview(Uint8List pdfBytes, String filename) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PdfPreviewPage(
          pdfBytes: pdfBytes,
          filename: filename,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final numberFormat = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Отчёт',
        onBackPressed: () => context.pop(),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSelectionBar(filtered),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final record = filtered[index];
                      final isSelected = _selectedIds.contains(record.id);
                      return _buildRecordTile(
                        record,
                        isSelected,
                        dateFormat,
                        numberFormat,
                      );
                    },
                  ),
          ),
          _buildBottomBar(numberFormat),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = <ServiceCategory>{};
    for (final r in _sortedRecords) {
      categories.add(r.category);
    }
    final sortedCategories = categories.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildChip(
            label: 'Все',
            isSelected: _filterCategory == null,
            onTap: () => setState(() => _filterCategory = null),
          ),
          ...sortedCategories.map(
            (cat) => _buildChip(
              label: cat.label,
              isSelected: _filterCategory == cat,
              onTap: () => setState(() {
                _filterCategory = _filterCategory == cat ? null : cat;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar(List<ServiceRecordEntity> filtered) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            'Выбрано: $_selectedCount из ${_sortedRecords.length}',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleAll,
            child: Text(
              _allFilteredSelected ? 'Снять все' : 'Выбрать все',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(
    ServiceRecordEntity record,
    bool isSelected,
    DateFormat dateFormat,
    NumberFormat numberFormat,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => _toggleRecord(record.id),
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (record.cost != null)
                          Text(
                            numberFormat.format(record.cost),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          record.category.icon,
                          size: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          record.category.label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          dateFormat.format(record.date),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${record.mileage} км',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(NumberFormat numberFormat) {
    final selectedRecords =
        _sortedRecords.where((r) => _selectedIds.contains(r.id));
    final totalCost = selectedRecords
        .where((r) => r.cost != null)
        .fold<double>(0, (sum, r) => sum + r.cost!);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedIds.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого по выбранным:',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    numberFormat.format(totalCost),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty || _isGenerating
                    ? null
                    : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: _isGenerating
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _selectedIds.isEmpty
                            ? 'Выберите записи'
                            : 'Сформировать отчёт ($_selectedCount)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 48.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(height: 12.h),
          Text(
            'Нет записей в этой категории',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String filename;

  const _PdfPreviewPage({
    required this.pdfBytes,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Предпросмотр',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            onPressed: () async {
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: filename,
              );
            },
            icon: Icon(
              Icons.share_outlined,
              size: 22.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => pdfBytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: filename,
        actions: const [],
      ),
    );
  }
}

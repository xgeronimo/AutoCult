import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/garage/domain/entities/car_entity.dart';
import '../../features/service_records/domain/entities/service_record_entity.dart';

class PdfReportService {
  pw.Font? _regularFont;
  pw.Font? _boldFont;

  Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;
    final regularData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  Future<Uint8List> generateServiceReport({
    required CarEntity car,
    required List<ServiceRecordEntity> records,
  }) async {
    await _loadFonts();

    final dateFormat = DateFormat('dd.MM.yyyy');
    final numberFormat =
        NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    final sorted = List<ServiceRecordEntity>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalCost = sorted
        .where((r) => r.cost != null)
        .fold<double>(0, (sum, r) => sum + r.cost!);

    final theme = pw.ThemeData.withFont(
      base: _regularFont!,
      bold: _boldFont!,
    );

    final pdf = pw.Document(theme: theme);

    final primaryColor = PdfColor.fromHex('#34C37A');
    final headerBg = PdfColor.fromHex('#F4F4F6');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            _buildHeader(car, dateFormat, primaryColor, context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(
            sorted,
            totalCost,
            numberFormat,
            dateFormat,
            car,
            primaryColor,
            headerBg,
          ),
          pw.SizedBox(height: 24),
          _buildRecordsTable(
            sorted,
            dateFormat,
            numberFormat,
            primaryColor,
            headerBg,
          ),
          pw.SizedBox(height: 24),
          _buildDetailedRecords(
            sorted,
            dateFormat,
            numberFormat,
            primaryColor,
            headerBg,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    CarEntity car,
    DateFormat dateFormat,
    PdfColor primaryColor,
    pw.Context context,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Отчёт по обслуживанию',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  car.fullNameWithYear,
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'AutoCult',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  dateFormat.format(DateTime.now()),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: primaryColor, thickness: 2),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Страница ${context.pageNumber} из ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }

  pw.Widget _buildSummarySection(
    List<ServiceRecordEntity> records,
    double totalCost,
    NumberFormat numberFormat,
    DateFormat dateFormat,
    CarEntity car,
    PdfColor primaryColor,
    PdfColor headerBg,
  ) {
    final earliest =
        records.isNotEmpty ? records.last.date : DateTime.now();
    final latest =
        records.isNotEmpty ? records.first.date : DateTime.now();
    final maxMileage = records.isNotEmpty
        ? records.map((r) => r.mileage).reduce((a, b) => a > b ? a : b)
        : car.mileage;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: headerBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Сводная информация',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('Записей', '${records.length}'),
              _summaryItem('Общая сумма', numberFormat.format(totalCost)),
              _summaryItem('Пробег', '$maxMileage км'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _summaryItem(
                'Период',
                '${dateFormat.format(earliest)} — ${dateFormat.format(latest)}',
              ),
              pw.Spacer(),
              if (car.vin != null && car.vin!.isNotEmpty)
                _summaryItem('VIN', car.vin!),
            ],
          ),
          if (car.licensePlate != null && car.licensePlate!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                _summaryItem('Гос. номер', car.licensePlate!),
                pw.Spacer(),
                _summaryItem('Топливо', car.fuelType.label),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildRecordsTable(
    List<ServiceRecordEntity> records,
    DateFormat dateFormat,
    NumberFormat numberFormat,
    PdfColor primaryColor,
    PdfColor headerBg,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Сводная таблица',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(3),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerBg),
              children: [
                _tableHeaderCell('Дата'),
                _tableHeaderCell('Категория'),
                _tableHeaderCell('Название'),
                _tableHeaderCell('Пробег', pw.Alignment.center),
                _tableHeaderCell('Стоимость', pw.Alignment.centerRight),
              ],
            ),
            ...records.map((record) {
              return pw.TableRow(
                children: [
                  _tableCell(dateFormat.format(record.date)),
                  _tableCell(record.category.label),
                  _tableCell(record.title),
                  _tableCell(
                    '${record.mileage}',
                    pw.Alignment.center,
                  ),
                  _tableCell(
                    record.cost != null
                        ? numberFormat.format(record.cost)
                        : '—',
                    pw.Alignment.centerRight,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDetailedRecords(
    List<ServiceRecordEntity> records,
    DateFormat dateFormat,
    NumberFormat numberFormat,
    PdfColor primaryColor,
    PdfColor headerBg,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Детализация',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 12),
        ...records.map((record) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          record.title,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        dateFormat.format(record.date),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      _detailChip(
                          '${record.category.icon} ${record.category.label}'),
                      pw.SizedBox(width: 8),
                      _detailChip('${record.mileage} км'),
                      if (record.cost != null) ...[
                        pw.SizedBox(width: 8),
                        _detailChip(numberFormat.format(record.cost)),
                      ],
                    ],
                  ),
                  if (record.serviceStation != null &&
                      record.serviceStation!.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'СТО: ',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.TextSpan(
                            text: record.serviceStation!,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (record.description != null &&
                      record.description!.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(
                      record.description!,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ],
              ),
            )),
      ],
    );
  }

  pw.Widget _detailChip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F4F4F6'),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  pw.Widget _tableHeaderCell(String text,
      [pw.Alignment alignment = pw.Alignment.centerLeft]) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tableCell(String text,
      [pw.Alignment alignment = pw.Alignment.centerLeft]) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: alignment,
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }
}

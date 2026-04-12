import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static Future<Uint8List> generateReceipt({
    required String receiptNumber,
    required String patientName,
    required String patientNumber,
    required double amount,
    required String paymentMethod,
    required DateTime paymentDate,
    required String facilityName,
    String? invoiceNumber,
    double? balance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(facilityName),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              _buildReceiptInfo(receiptNumber, paymentDate),
              pw.SizedBox(height: 20),
              _buildPatientInfo(patientName, patientNumber),
              if (invoiceNumber != null) ...[
                pw.SizedBox(height: 12),
                _buildInfoRow('Invoice Number', invoiceNumber),
              ],
              pw.SizedBox(height: 12),
              _buildInfoRow('Payment Method', paymentMethod.toUpperCase()),
              pw.Divider(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Amount Paid:',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _currencyFormat.format(amount),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
                ],
              ),
              if (balance != null && balance > 0) ...[
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Balance:', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(
                      _currencyFormat.format(balance),
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              pw.Divider(height: 30),
              pw.Spacer(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your payment!',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Please retain this receipt for your records.',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateDischargeSummary({
    required String patientName,
    required String patientNumber,
    required DateTime admissionDate,
    required DateTime dischargeDate,
    required String wardName,
    required String bedNumber,
    required String admittingDoctor,
    required String diagnosis,
    required List<String> procedures,
    required List<String> medications,
    required String dischargeInstructions,
    required String facilityName,
    String? followUpDate,
    String? dischargeNotes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return [
            _buildHeader(facilityName),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'DISCHARGE SUMMARY',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSectionTitle('Patient Information'),
            _buildInfoRow('Patient Name', patientName),
            _buildInfoRow('Patient Number', patientNumber),
            pw.SizedBox(height: 16),
            _buildSectionTitle('Admission Details'),
            _buildInfoRow('Admission Date', _dateTimeFormat.format(admissionDate)),
            _buildInfoRow('Discharge Date', _dateTimeFormat.format(dischargeDate)),
            _buildInfoRow('Ward', wardName),
            _buildInfoRow('Bed', bedNumber),
            _buildInfoRow('Admitting Doctor', admittingDoctor),
            pw.SizedBox(height: 16),
            _buildSectionTitle('Diagnosis'),
            pw.Text(diagnosis, style: const pw.TextStyle(fontSize: 12)),
            if (procedures.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildSectionTitle('Procedures Performed'),
              ...procedures.map((p) => pw.Bullet(text: p)),
            ],
            pw.SizedBox(height: 16),
            _buildSectionTitle('Medications on Discharge'),
            ...medications.map((m) => pw.Bullet(text: m)),
            pw.SizedBox(height: 16),
            _buildSectionTitle('Discharge Instructions'),
            pw.Text(
              dischargeInstructions,
              style: const pw.TextStyle(fontSize: 12),
            ),
            if (followUpDate != null) ...[
              pw.SizedBox(height: 16),
              _buildInfoRow('Follow-up Date', followUpDate),
            ],
            if (dischargeNotes != null) ...[
              pw.SizedBox(height: 16),
              _buildSectionTitle('Additional Notes'),
              pw.Text(
                dischargeNotes,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 200,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(),
                        ),
                      ),
                      height: 30,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Doctor\'s Signature', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 200,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(),
                        ),
                      ),
                      height: 30,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Patient/Guardian Signature', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (context) => _buildFooter(),
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateLabReport({
    required String patientName,
    required String patientNumber,
    required String orderNumber,
    required DateTime collectedDate,
    required String testName,
    required String result,
    required String unit,
    required String normalRange,
    required String resultStatus,
    required String performedBy,
    required String facilityName,
    String? notes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          final isAbnormal = resultStatus == 'high' || resultStatus == 'low' || resultStatus == 'critical';
          
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(facilityName),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'LABORATORY REPORT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              _buildInfoRow('Order Number', orderNumber),
              _buildInfoRow('Patient', patientName),
              _buildInfoRow('Patient Number', patientNumber),
              _buildInfoRow('Collection Date', _dateTimeFormat.format(collectedDate)),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),
              _buildSectionTitle('Test Results'),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: isAbnormal ? PdfColors.orange50 : PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      testName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Result', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(
                              '$result $unit',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: isAbnormal ? PdfColors.orange800 : PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('Reference Range', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(
                              normalRange,
                              style: const pw.TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _getStatusColor(resultStatus),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        resultStatus.toUpperCase(),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                _buildSectionTitle('Notes'),
                pw.Text(notes, style: const pw.TextStyle(fontSize: 11)),
              ],
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Performed by: $performedBy',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Date: ${_dateTimeFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateInvoice({
    required String invoiceNumber,
    required String patientName,
    required String patientNumber,
    required DateTime invoiceDate,
    required DateTime? dueDate,
    required List<InvoiceItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double amountPaid,
    required double balance,
    required String facilityName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(facilityName),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      )),
                      pw.SizedBox(height: 4),
                      pw.Text('Invoice #: $invoiceNumber', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Date: ${_dateFormat.format(invoiceDate)}', style: const pw.TextStyle(fontSize: 12)),
                      if (dueDate != null)
                        pw.Text('Due: ${_dateFormat.format(dueDate)}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildSectionTitle('Bill To'),
              pw.Text(patientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Patient #: $patientNumber', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              _buildItemsTable(items),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      _buildTotalRow('Subtotal', subtotal),
                      if (discount > 0) _buildTotalRow('Discount', -discount),
                      if (tax > 0) _buildTotalRow('Tax', tax),
                      pw.Divider(),
                      _buildTotalRow('Total', total, isBold: true),
                      _buildTotalRow('Amount Paid', -amountPaid),
                      pw.Divider(),
                      _buildTotalRow('Balance Due', balance, isBold: true, color: PdfColors.red700),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Thank you for choosing our facility.',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String facilityName) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            facilityName,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  static pw.Widget _buildReceiptInfo(String receiptNumber, DateTime date) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Receipt #: $receiptNumber'),
          pw.Text(_dateTimeFormat.format(date)),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(String name, String number) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Patient Name', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Patient #', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(number, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Unit Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...items.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item.description),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item.quantity.toStringAsFixed(0)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(_currencyFormat.format(item.unitPrice)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(_currencyFormat.format(item.total)),
            ),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isBold ? 14 : 12,
            ),
          ),
          pw.Text(
            _currencyFormat.format(amount.abs()),
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isBold ? 14 : 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return PdfColors.green700;
      case 'high':
      case 'low':
        return PdfColors.orange700;
      case 'critical':
        return PdfColors.red700;
      default:
        return PdfColors.grey600;
    }
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.only(top: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'OpenHealth Healthcare Management System',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
          pw.Text(
            'This is a computer-generated document. No signature required.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
          ),
        ],
      ),
    );
  }

  static Future<void> printPdf(Uint8List pdfData, String title) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: title,
    );
  }

  static Future<void> sharePdf(Uint8List pdfData, String filename) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: '$filename.pdf',
    );
  }
}

class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

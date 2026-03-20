import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportService {
  /// Generates and previews a PDF report for a specific batch or farm overview
  static Future<void> generateFarmReport({
    required String farmName,
    required List<Map<String, dynamic>> batchData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('KukuFiti - Farm Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Farm: $farmName'),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Batch ID', 'Breed', 'Initial Count', 'Current Age'],
                  ...batchData.map((batch) => [
                        batch['id'].toString(),
                        batch['breed'].toString(),
                        batch['initialCount'].toString(),
                        '${batch['age']} days',
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

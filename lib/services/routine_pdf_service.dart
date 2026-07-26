import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/routine_item_model.dart';

class RoutinePdfService {
  static Future<void> exportAndPrintPdf({
    required List<RoutineItemModel> routines,
    required String semester,
    required String section,
    required String group,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CampusOne Smart Routine',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Personalized Timetable for $semester | Sec $section | $group',
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                data: <List<String>>[
                  <String>['Day', 'Time', 'Subject', 'Code', 'Teacher', 'Room'],
                  ...routines.map((item) => [
                        item.dayOfWeek,
                        '${item.startTime} - ${item.endTime}',
                        item.subjectName,
                        item.courseCode,
                        item.teacherName,
                        item.roomNo,
                      ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated automatically via CampusOne App (Offline First Engine)',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

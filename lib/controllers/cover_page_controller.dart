import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/hive_service.dart';
import '../constants/hive_box_keys.dart';
import '../models/cover_page_model.dart';
import '../models/student_profile_model.dart';

class CoverPageController extends ChangeNotifier {
  List<CoverPageModel> _templates = [];

  CoverPageController() {
    _loadData();
  }

  List<CoverPageModel> get templates => _templates;

  void _loadData() {
    final box = HiveService.instance.coverPagesBox;
    _templates = box.values.toList();
    notifyListeners();
  }

  CoverPageModel createDefaultTemplate() {
    final profileBox = HiveService.instance.userProfileBox;
    StudentProfileModel? profile = profileBox.get(HiveBoxKeys.studentProfileKey);

    return CoverPageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Cover Page',
      studentName: profile?.name ?? '',
      studentId: '2026-CAMPUS-01', // Example default since profile doesn't have ID by default in some views
      department: profile?.department ?? '',
      semester: profile?.semester ?? '',
      section: profile?.section ?? '',
      courseName: 'Software Engineering',
      courseCode: 'CSE301',
      teacherName: 'Dr. John Doe',
      submissionDate: DateTime.now(),
      universityName: profile?.university ?? 'My University',
    );
  }

  Future<void> saveTemplate(CoverPageModel template) async {
    await HiveService.instance.coverPagesBox.put(template.id, template);
    _loadData();
  }

  Future<void> deleteTemplate(String id) async {
    await HiveService.instance.coverPagesBox.delete(id);
    _loadData();
  }

  Future<Uint8List> generatePdf(CoverPageModel template) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 40),
                pw.Text(
                  template.universityName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Department of ${template.department}',
                  style: pw.TextStyle(fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  'ASSIGNMENT',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 40),
                _buildRow('Course Name:', template.courseName),
                pw.SizedBox(height: 10),
                _buildRow('Course Code:', template.courseCode),
                pw.SizedBox(height: 10),
                _buildRow('Topic:', template.title),
                
                pw.Spacer(),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Submitted To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.SizedBox(height: 5),
                        pw.Text(template.teacherName, style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Submitted By:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.SizedBox(height: 5),
                        pw.Text('Name: ${template.studentName}', style: const pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(height: 2),
                        pw.Text('ID: ${template.studentId}', style: const pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(height: 2),
                        pw.Text('Semester: ${template.semester}', style: const pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(height: 2),
                        pw.Text('Section: ${template.section}', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 50),
                pw.Text(
                  'Date of Submission: ${template.submissionDate.day}/${template.submissionDate.month}/${template.submissionDate.year}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}


import 'dart:io';

import 'package:grocery/save_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class SimplePdfAPI {
  Future<void> generateTextPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text("hello", style: pw.TextStyle(fontSize: 47, )),
              pw.SizedBox(height: 10),
              pw.Text("text2", style: pw.TextStyle(fontSize: 47, )),
            ],
          ),
        ),
      ),
    );

    Directory root = await getApplicationDocumentsDirectory();
    String path = '${root.path}/test.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    print("path "+path);
  }
}

// User class for table data
class User {
  final String name;
  final int age;

  const User({required this.name, required this.age});
}

class TablePdfApi {
  Future<File> generatePdf() async {
    final pdf = pw.Document();

    // Define headers and data for the table
    final headers = ['Name', 'Age'];
    final users = [
      const User(name: 'John Doe', age: 30),
      const User(name: 'Jane Smith', age: 25),
    ];
    final data = users.map((user) => [user.name, user.age.toString()]).toList();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontSize: 16), // Default Helvetica font
          cellStyle: pw.TextStyle(fontSize: 14),   // Default Helvetica font
        ),
      ),
    );

    // Save the PDF
    return SaveAndOpenDirectory().savePdf(name: 'table_pdf.pdf', pdf: pdf);
  }
}



class PdfReportAPI {
  // Future<File> generateReportPdf({
  //   required Map<String, dynamic> reportData,
  //   required List<Map<String, dynamic>> reportMemberData,
  //   required List<dynamic> transactions,
  // }) async {
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       build: (context) => [
  //         pw.Text('Event Report: Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //         pw.SizedBox(height: 10),
  //         _buildSummaryCard(reportData),
  //         pw.SizedBox(height: 20),
  //
  //         pw.Text('Pie Chart Data (as text)', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //         _buildPieChartData(reportData),
  //         pw.SizedBox(height: 20),
  //
  //         pw.Text('Transactions', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //         _buildTransactionTable(transactions),
  //         pw.SizedBox(height: 20),
  //
  //         pw.Text('Member Details', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //         _buildTable(reportMemberData),
  //       ],
  //     ),
  //   );
  //
  //   Directory? downloadsDir = Directory('/storage/emulated/0/Download');
  //   if (!downloadsDir.existsSync()) {
  //     downloadsDir = await getExternalStorageDirectory();
  //   }
  //
  //   final filePath = '${downloadsDir!.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //   final file = File(filePath);
  //   await file.writeAsBytes(await pdf.save());
  //
  //   print("PDF saved at: $filePath");
  //   return file;
  // }



  //
  // static pw.Widget _buildSummaryCard(Map<String, dynamic> reportData) {
  //   return pw.Container(
  //     padding: pw.EdgeInsets.all(16),
  //     decoration: pw.BoxDecoration(
  //       border: pw.Border.all(color: PdfColors.black),
  //       borderRadius: pw.BorderRadius.circular(12),
  //     ),
  //     child: pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         _summaryRow("Total Members:", reportData['totalMembers'].toString()),
  //         _summaryRow("Total Income:", reportData['totalIncome'].toString()),
  //         _summaryRow("Total Expense:", reportData['totalExpense'].toString()),
  //         _summaryRow("Expense Per Head:", reportData['expensePerHead'].toStringAsFixed(2)),
  //       ],
  //     ),
  //   );
  // }
  //
  // static pw.Widget _buildTable(List<Map<String, dynamic>> reportMemberData) {
  //   return pw.Table.fromTextArray(
  //     headers: ['Member', 'Income', 'Expense'],
  //     data: reportMemberData.map((row) => [
  //       row['member'].toString(),
  //       row['income'].toString(),
  //       row['expense'].toString(),
  //     ]).toList(),
  //     headerStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
  //     cellStyle: pw.TextStyle(fontSize: 16),
  //     headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
  //     cellAlignments: {
  //       0: pw.Alignment.centerLeft,
  //       1: pw.Alignment.centerRight,
  //       2: pw.Alignment.centerRight,
  //     },
  //   );
  // }
  //
  // static pw.Widget _summaryRow(String label, String value) {
  //   return pw.Row(
  //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //     children: [
  //       pw.Text(label, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
  //       pw.Text(value, style: pw.TextStyle(fontSize: 16)),
  //     ],
  //   );
  // }
}



import 'package:flutter/material.dart';
import 'package:grocery/PersonScreen.dart';
import 'package:grocery/ReportAPI.dart';
import 'package:grocery/ReportScreen.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:grocery/TransactionScreen.dart';
import 'package:grocery/savePDF.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class ExpenseDetail extends StatefulWidget {
  final String eventName;
  final int eventId;

  ExpenseDetail({required this.eventName, required this.eventId});

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchReportScreen();
    _fetchMember();
    _fetchTransactions();
  }
  Future<void> _fetchTransactions() async {
    try {
      List<dynamic> transactions = await TransactionAPI().getTransactionByEvent(widget.eventId);
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }


  Future<void> _fetchMember() async {
    try {
      List<Map<String, dynamic>> reportMemberData = await ReportAPI().getTransactionodMember(widget.eventId);
      setState(() {
        _reportMemberData = reportMemberData;
      });
    } catch (e) {
      print("Error fetching report data: $e");
    }
  }

  Future<void> _fetchReportScreen() async {
    try {
      Map<String, dynamic> reportData = await ReportAPI().getAllReport(widget.eventId);
      List<dynamic> transactions = await TransactionAPI().getTransactionByEvent(widget.eventId);

      setState(() {
        _reportData = reportData;
        _transactions = transactions;
      });
    } catch (e) {
      print("Error fetching report data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF3E4FBD),
          title: Text(
            widget.eventName,
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: "PERSON"),
              Tab(text: "TRANSACTION"),
              Tab(text: "REPORT"),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              onPressed: () async {
                await _fetchReportScreen();
                await _fetchMember();

                if (_reportData.isNotEmpty && _reportMemberData.isNotEmpty) {
                  final pdfFile = await PdfReportAPI().generateReportPdf(
                    reportData: _reportData,
                    reportMemberData: _reportMemberData,
                    transactions: _transactions,
                  );

                  SaveAndOpenDirectory.openPdf(pdfFile);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Color(0xFF3E4FBD)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "PDF is Downloaded successfully! $pdfFile",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No data available to generate PDF')),
                  );
                }
              },

              // onPressed: () async {
              //   if (_reportData.isNotEmpty && _reportMemberData.isNotEmpty) {
              //     final pdfFile = await PdfReportAPI().generateReportPdf(
              //       reportData: _reportData,
              //       reportMemberData: _reportMemberData,
              //       transactions: _transactions
              //
              //     );
              //
              //     SaveAndOpenDirectory.openPdf(pdfFile);
              //
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Row(
              //           children: [
              //             Icon(Icons.picture_as_pdf, color: Color(0xFF3E4FBD)), // Icon on the left
              //             SizedBox(width: 8), // Space between icon and text
              //             Expanded(
              //               child: Text(
              //                 "PDF is Dawnload successfully! $pdfFile",
              //                 style: TextStyle(
              //                   color: Colors.black,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //         behavior: SnackBarBehavior.floating, // Floating Snackbar
              //         backgroundColor: Colors.white, // White background
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12), // Rounded corners
              //         ),
              //         margin: EdgeInsets.all(16), // Margin for floating effect
              //         duration: Duration(seconds: 3), // Visibility duration
              //       ),
              //     );
              //   } else {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('No data available to generate PDF')),
              //     );
              //   }
              // },
            ),
          ],
        ),
        body:
        TabBarView(
          children: [
            PersonScreen(eventName: widget.eventName, eventId: widget.eventId),
            DashboardScreen(eventName: widget.eventName, eventId: widget.eventId),
            ReportScreen(eventId: widget.eventId, eventName: widget.eventName),
          ],
        ),
      ),
    );
  }
}

class PdfReportAPI {
  Future<File> generateReportPdf({
    required Map<String, dynamic> reportData,
    required List<Map<String, dynamic>> reportMemberData,
    required List<dynamic> transactions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Event Report: Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildSummaryCard(reportData),
          pw.SizedBox(height: 20),

          pw.Text('Pie Chart Data (as text)', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          _buildPieChartData(reportData),
          pw.SizedBox(height: 20),

          pw.Text('Transactions', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 20),

          pw.Text('Member Details', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          _buildTable(reportMemberData),
        ],
      ),
    );

    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
   

    final filePath = '${downloadsDir!.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: $filePath");
    return file;
  }

  static pw.Widget _buildPieChartData(Map<String, dynamic> reportData) {
    double totalIncome = (reportData['totalIncome'] ?? 0).toDouble();
    double totalExpense = (reportData['totalExpense'] ?? 0).toDouble();
    double remaining = totalIncome - totalExpense;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _summaryRow('Income:', '${totalIncome.toStringAsFixed(2)}'),
        _summaryRow('Expense:', '${totalExpense.toStringAsFixed(2)}'),
        _summaryRow('Remaining:', '${remaining.toStringAsFixed(2)}'),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(List<dynamic> transactions) {
    final data = transactions.map((tx) {
      final isCredit = tx['transactionType'] == 'credit';
      final amount = (tx['amount'] as num).toDouble();
      final date = tx['transactionDate'].toString().split('T')[0];

      return [
        tx['userName'],
        date,
        isCredit ? 'Credit' : 'Debit',
        '${amount.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Name', 'Date', 'Type', 'Amount'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: 14),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildSummaryCard(Map<String, dynamic> reportData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _summaryRow("Total Members:", reportData['totalMembers'].toString()),
          _summaryRow("Total Income:", reportData['totalIncome'].toString()),
          _summaryRow("Total Expense:", reportData['totalExpense'].toString()),
          _summaryRow("Expense Per Head:", reportData['expensePerHead'].toStringAsFixed(2)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> reportMemberData) {
    return pw.Table.fromTextArray(
      headers: ['Member', 'Income', 'Expense', 'Remaining'],
      data: reportMemberData.map((row) {
        final income = (row['income'] ?? 0).toDouble();
        final expense = (row['expense'] ?? 0).toDouble();
        final remaining = income - expense;

        return [
          row['member'].toString(),
          income.toStringAsFixed(2),
          expense.toStringAsFixed(2),
          remaining.toStringAsFixed(2),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: 16),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }


  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold,)),
        pw.Text(value, style: pw.TextStyle(fontSize: 16)),
      ],
    );
  }
}


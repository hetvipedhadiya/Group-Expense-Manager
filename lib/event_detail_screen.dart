import 'package:flutter/material.dart';
import 'package:grocery/person_list_screen.dart';
import 'package:grocery/report_database.dart';
import 'package:grocery/report_screen.dart';
import 'package:grocery/transaction_database.dart';
import 'package:grocery/transaction_list_screen.dart';
import 'package:grocery/save_pdf.dart';
import 'package:grocery/theme_manager.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class EventDetailScreen extends StatefulWidget {
  final String eventName;
  final int eventId;

  EventDetailScreen({required this.eventName, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    await _fetchReportScreen();
    await _fetchMember();
    await _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions =
          await TransactionDatabase().getTransactionByEvent(widget.eventId);
      if (mounted) setState(() => _transactions = transactions);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchMember() async {
    try {
      final data = await ReportDatabase().getTransactionodMember(widget.eventId);
      if (mounted) setState(() => _reportMemberData = data);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchReportScreen() async {
    try {
      final data = await ReportDatabase().getAllReport(widget.eventId);
      if (mounted) setState(() => _reportData = data);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFEDF1F4) : const Color(0xFF0D0D1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isLight ? const Color(0xFF1E293B) : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.eventName,
          style: TextStyle(
            color: isLight ? const Color(0xFF1E293B) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: isLight ? const Color(0xFF1E293B) : Colors.white),
            onPressed: () async {
              await _fetchAll();
              if (_reportData.isNotEmpty && _reportMemberData.isNotEmpty) {
                try {
                  final pdfFile = await PdfReportAPI().generateReportPdf(
                    reportData: _reportData,
                    reportMemberData: _reportMemberData,
                    transactions: _transactions,
                  );
                  SaveAndOpenDirectory.openPdf(pdfFile);
                } catch (e) {
                  _showToast('Error generating PDF', isError: true);
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1E293B),
          indicatorWeight: 3,
          labelColor: const Color(0xFF1E293B),
          unselectedLabelColor: Colors.black38,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          tabs: const [
            Tab(text: 'PEOPLE'),
            Tab(text: 'HISTORY'),
            Tab(text: 'INSIGHTS'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight 
              ? [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)] 
              : [const Color(0xFF0D0D1F), const Color(0xFF1A1040)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            PersonListScreen(eventName: widget.eventName, eventId: widget.eventId),
            TransactionListScreen(eventName: widget.eventName, eventId: widget.eventId),
            ReportScreen(eventId: widget.eventId, eventName: widget.eventName),
          ],
        ),
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Event Report: Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        
        // Summary Box
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Members:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)), pw.Text(reportData['totalMembers']?.toString() ?? '0', style: const pw.TextStyle(fontSize: 14))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Income:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)), pw.Text(reportData['totalIncome']?.toString() ?? '0.0', style: const pw.TextStyle(fontSize: 14))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Expense:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)), pw.Text(reportData['totalExpense']?.toString() ?? '0.0', style: const pw.TextStyle(fontSize: 14))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Expense Per Head:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)), pw.Text(reportData['expensePerHead']?.toString() ?? '0.0', style: const pw.TextStyle(fontSize: 14))]),
            ]
          )
        ),
        
        pw.SizedBox(height: 25),
        
        // Transactions Table
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['Name', 'Date', 'Type', 'Amount'],
          data: transactions.map((t) {
            final dateStr = (t['transactionDate']?.toString() ?? '').split('T')[0];
            final typeStr = (t['transactionType']?.toString().toLowerCase() == 'credit') ? 'Credit' : 'Debit';
            return [
              t['userName']?.toString() ?? 'Member',
              dateStr,
              typeStr,
              t['amount']?.toString() ?? '0',
            ];
          }).toList(),
          cellStyle: const pw.TextStyle(fontSize: 12),
          headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        
        pw.SizedBox(height: 25),

        // Member Details Table
        pw.Text('Member Details', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['Member', 'Income', 'Expense', 'Remaining'],
          data: reportMemberData.map((row) => [
            row['member']?.toString() ?? '',
            (row['income'] ?? 0).toString(),
            (row['expense'] ?? 0).toString(),
            ((row['income'] ?? 0) - (row['expense'] ?? 0)).toString(),
          ]).toList(),
          cellStyle: const pw.TextStyle(fontSize: 12),
          headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    ));
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    }
    final file = File('${downloadsDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}




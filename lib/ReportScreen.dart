import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grocery/ReportAPI.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class ReportScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  ReportScreen({required this.eventId, required this.eventName});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];

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


  @override
  void initState() {
    super.initState();
    _fetchReportScreen();
    _fetchMember();
    _fetchTransactions();
  }

  Future<void> _fetchMember() async {
    try {
      List<Map<String, dynamic>> reportMemberData =
      await ReportAPI().getTransactionodMember(widget.eventId);
      setState(() {
        _reportMemberData = reportMemberData;
      });
    } catch (e) {
      print("Error fetching report data: $e");
    }
  }

  void _fetchReportScreen() async {
    try {
      Map<String, dynamic> reportData =
      await ReportAPI().getAllReport(widget.eventId);
      setState(() {
        _reportData = reportData;
      });
    } catch (e) {
      print("Error fetching report data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (_reportData.isNotEmpty) FadeInDown(child: _buildSummaryCard()),
              const SizedBox(height: 20,),
              if (_transactions.isNotEmpty)
                FadeIn(child: _buildTransactionSection(_transactions)),
              const SizedBox(height: 20),
              FadeInUp(child: _buildPieChart()),
              const SizedBox(height: 20),
              FadeIn(child: _buildTable()),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(List<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.map((transaction) {
        bool isCredit = transaction['transactionType'] == 'credit';
        double amount = (transaction['amount'] as num).toDouble();
        String formattedAmount = "₹${NumberFormat("#,##0.00", "en_IN").format(amount)}";

        return Container(
          color: Colors.white,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green : Colors.red,
                child: Icon(Icons.category, color: Colors.white),
              ),
              title: Text(
                transaction['userName'],
                style: TextStyle(fontWeight: FontWeight.bold, color : Colors.black,fontSize: 16),
              ),
              subtitle: Text(
                transaction['transactionDate'].toString().split('T')[0],
                style: TextStyle(fontSize: 15,color: Colors.black),
              ),
              trailing: Text(
                formattedAmount,
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Color(0xFF1B1B2F), Color(0xFF162447)],
          // ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow("Total Income:", _reportData['totalIncome'] ?? 0, Colors.green),
            _summaryRow("Total Expense:", _reportData['totalExpense'] ?? 0, Colors.pinkAccent),
            _summaryRow("Expense Per Head:", _reportData['expensePerHead'] ?? 0, Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, num value, Color color) {
    final currencyFormat = NumberFormat.currency(locale: "en_IN", symbol: "₹");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(currencyFormat.format(value), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    double totalIncome = (_reportData['totalIncome'] ?? 0).toDouble();
    double totalExpense = (_reportData['totalExpense'] ?? 0).toDouble();
    double remainingAmount = totalIncome - totalExpense;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Color(0xFF1B1B2F), Color(0xFF162447)],
          // ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text("Financial Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                  sections: [
                    PieChartSectionData(color: Color(0xFF00FFCC), value: totalIncome, title: 'Income', radius: 90, titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Color(0xFFFF3366), value: totalExpense, title: 'Expense', radius: 90, titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Color(0xFF3366FF), value: remainingAmount, title: 'Remaining', radius: 90, titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final currencyFormat = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Card(

      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          //gradient: LinearGradient(colors: [Color(0xFF1B1B2F), Color(0xFF162447)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Members Summary", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              border: TableBorder(horizontalInside: BorderSide(color: Colors.grey, width: 0.3)),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.white12),
                  children: [
                    _tableHeaderCell("Member"),
                    _tableHeaderCell("Income"),
                    _tableHeaderCell("Expense"),
                    _tableHeaderCell("Remaining"),
                  ],
                ),
                ..._reportMemberData.map((row) {
                  final income = (row['income'] ?? 0).toDouble();
                  final expense = (row['expense'] ?? 0).toDouble();
                  final remaining = income - expense;

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row['member'],style: TextStyle(
                          color: Colors.black
                        ),
                        ),


                      ),
                   //   _tableTextCell(row['member'].toString(), Colors.white),
                      _tableTextCell(currencyFormat.format(income), Colors.green),
                      _tableTextCell(currencyFormat.format(expense), Colors.pinkAccent),
                      _tableTextCell(
                        currencyFormat.format(remaining.abs()),
                        remaining >= 0 ? Colors.green : Colors.redAccent,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableTextCell(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

}
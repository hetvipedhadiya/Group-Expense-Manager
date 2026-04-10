import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grocery/ReportAPI.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:grocery/theme_manager.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  ReportScreen({required this.eventId, required this.eventName});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  bool _showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final data = await ReportAPI().getAllReport(widget.eventId);
      final members = await ReportAPI().getTransactionodMember(widget.eventId);
      final txns = await TransactionAPI().getTransactionByEvent(widget.eventId);
      if (mounted) {
        setState(() {
          _reportData = data;
          _reportMemberData = members;
          _transactions = txns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    final isLight = ThemeManager.instance.isLightMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. OVERVIEW DONUT CHART (Matching Image 4)
              _buildDonutOverview(isLight),
              const SizedBox(height: 24),

              // 2. TOTAL CARDS (Matching Image 3 & 4)
              Row(
                children: [
                  Expanded(child: _SummaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Total Income',
                    value: '₹${NumberFormat("#,##0", "en_IN").format(_reportData['totalIncome'] ?? 0)}',
                    iconColor: const Color(0xFF10B981),
                    isLight: isLight,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _SummaryCard(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Total Expense',
                    value: '₹${NumberFormat("#,##0", "en_IN").format(_reportData['totalExpense'] ?? 0)}',
                    iconColor: const Color(0xFFEF4444),
                    isLight: isLight,
                  )),
                ],
              ),
              const SizedBox(height: 32),

              // 3. RECENT HISTORY (Matching Image 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent History', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => setState(() => _showAllHistory = !_showAllHistory),
                    child: Text(_showAllHistory ? 'Show Less' : 'See All', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHistoryList(isLight),
              const SizedBox(height: 32),

              // 4. MEMBER REPORT (Matching Image 3)
              const Text('Member Report', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMemberReportTable(isLight),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonutOverview(bool isLight) {
    final income = (_reportData['totalIncome'] ?? 0).toDouble();
    final expense = (_reportData['totalExpense'] ?? 0).toDouble();
    final balance = income - expense;
    final total = (income + expense) > 0 ? (income + expense) : 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isLight ? 0.04 : 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overview', style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(color: const Color(0xFF10B981), value: income > 0 ? income : 0.1, radius: 20, showTitle: false),
                      PieChartSectionData(color: const Color(0xFFEF4444), value: expense > 0 ? expense : 0.1, radius: 20, showTitle: false),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BALANCE', style: TextStyle(color: isLight ? Colors.black38 : Colors.white38, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${NumberFormat("#,##0", "en_IN").format(balance)}',
                        style: TextStyle(color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF10B981), label: 'Income', isLight: isLight),
              const SizedBox(width: 20),
              _LegendItem(color: const Color(0xFFEF4444), label: 'Expense', isLight: isLight),
              const SizedBox(width: 20),
              _LegendItem(color: isLight ? Colors.black12 : Colors.white12, label: 'Savings', isLight: isLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(bool isLight) {
    final items = _showAllHistory ? _transactions : (_transactions.length > 2 ? _transactions.take(2).toList() : _transactions);
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: items.map((tx) {
          final isCredit = tx['transactionType']?.toString().toLowerCase() == 'credit';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isLight ? 0.02 : 0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['userName'] ?? 'Member', style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(DateFormat('dd MMM, yyyy').format(DateTime.parse(tx['transactionDate'])), style: TextStyle(color: isLight ? Colors.black26 : Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'} ₹${NumberFormat("#,##0", "en_IN").format(tx['amount'] ?? 0)}',
                      style: TextStyle(color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(isCredit ? 'Income' : 'Expense', style: TextStyle(color: isCredit ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFFEF4444).withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemberReportTable(bool isLight) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isLight ? 0.03 : 0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: isLight ? const Color(0xFFF8FAFC) : Colors.white.withOpacity(0.03), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Member', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Income', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Expense', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Balance', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportMemberData.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.05)),
            itemBuilder: (ctx, i) {
              final row = _reportMemberData[i];
              final inc = (row['income'] ?? 0).toDouble();
              final exp = (row['expense'] ?? 0).toDouble();
              final bal = inc - exp;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(row['member'] ?? '', style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                    Expanded(child: Text('₹${NumberFormat("#,##0", "en_IN").format(inc)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    Expanded(child: Text('₹${NumberFormat("#,##0", "en_IN").format(exp)}', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    Expanded(child: Text('₹${NumberFormat("#,##0", "en_IN").format(bal)}', style: TextStyle(color: bal >= 0 ? const Color(0xFF34D399) : const Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w800), textAlign: TextAlign.right)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isLight;

  const _SummaryCard({required this.icon, required this.label, required this.value, required this.iconColor, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isLight ? 0.03 : 0.2), blurRadius: 10, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: isLight ? Colors.black38 : Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FittedBox(child: Text(value, style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLight;
  const _LegendItem({required this.color, required this.label, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: isLight ? Colors.black26 : Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
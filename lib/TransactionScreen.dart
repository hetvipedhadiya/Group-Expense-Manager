import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grocery/Person_Api.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:grocery/TransactionForm.dart';
import 'package:grocery/theme_manager.dart';

class DashboardScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  DashboardScreen({required this.eventId, required this.eventName});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  Future<List<dynamic>>? _transactionFuture;
  List<dynamic> _persons = [];
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadPersons();
    _transactionFuture = _fetchTransactions();
  }

  Future<void> _loadPersons() async {
    final persons = await PersonApi().getPersonsByEvent(widget.eventId);
    if (mounted) setState(() => _persons = persons);
  }

  Future<List<dynamic>> _fetchTransactions() => TransactionAPI().getTransactionByEvent(widget.eventId);

  void _refreshTransactions() {
    setState(() {
      _transactionFuture = _fetchTransactions();
    });
  }

  void _showTransactionActions(dynamic tx) {
    final isLight = ThemeManager.instance.isLightMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1040),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isLight ? Colors.black12 : Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Transaction',
              color: const Color(0xFF7C3AED),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionForm(eventID: widget.eventId, eventName: widget.eventName, map: tx)));
                if (result == true) _refreshTransactions();
              },
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.delete_outline,
              label: 'Delete Transaction',
              color: Colors.redAccent,
              onTap: () async {
                Navigator.pop(ctx);
                final deleted = await TransactionAPI().deleteTransaction(tx['expenseID']);
                if (deleted) _refreshTransactions();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final transactions = snapshot.data ?? [];
          final itemsToShow = _showAll ? transactions.length : (transactions.length > 3 ? 3 : transactions.length);

          return CustomScrollView(
            slivers: [
              // HEADER BALANCE CARD (Matching Image 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: _BalanceHeaderCard(transactions: transactions),
                ),
              ),

              // LIST SECTION HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showAll = !_showAll),
                        child: Text(_showAll ? 'Show Less' : 'View All', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),

              // TRANSACTIONS LIST
              if (transactions.isEmpty)
                SliverFillRemaining(child: Center(child: Text('No transactions added yet', style: TextStyle(color: isLight ? Colors.black26 : Colors.white24))))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        return _AnimatedTransactionCard(
                          tx: transactions[i],
                          index: i,
                          onTap: () => _showTransactionActions(transactions[i]),
                          isLight: isLight,
                        );
                      },
                      childCount: itemsToShow,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_persons.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a member first!')));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionForm(eventID: widget.eventId, eventName: widget.eventName, map: null))).then((val) {
              if (val == true) _refreshTransactions();
            });
          },
          backgroundColor: const Color(0xFF1E293B),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _BalanceHeaderCard extends StatelessWidget {
  final List<dynamic> transactions;
  const _BalanceHeaderCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    double income = transactions.where((t) => t['transactionType']?.toString().toLowerCase() == 'credit').fold(0.0, (s, t) => s + (t['amount'] as num).toDouble());
    double expense = transactions.where((t) => t['transactionType']?.toString().toLowerCase() == 'debit').fold(0.0, (s, t) => s + (t['amount'] as num).toDouble());
    double balance = income - expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3649), // Dark slate/blue card matching image
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Text('BALANCE', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 2)),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              '₹${NumberFormat("#,##0", "en_IN").format(balance)}',
              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(child: _MiniStat(label: 'INCOME', value: '₹${NumberFormat("#,##0", "en_IN").format(income)}', color: const Color(0xFF34D399))),
                Container(width: 1, height: 30, color: Colors.white10),
                Expanded(child: _MiniStat(label: 'EXPENSE', value: '₹${NumberFormat("#,##0", "en_IN").format(expense)}', color: const Color(0xFFFACC15))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AnimatedTransactionCard extends StatefulWidget {
  final dynamic tx;
  final int index;
  final VoidCallback onTap;
  final bool isLight;

  const _AnimatedTransactionCard({required this.tx, required this.index, required this.onTap, required this.isLight});

  @override
  State<_AnimatedTransactionCard> createState() => _AnimatedTransactionCardState();
}

class _AnimatedTransactionCardState extends State<_AnimatedTransactionCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // Low duration (snappy animation) as requested
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 30), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final isCredit = tx['transactionType']?.toString().toLowerCase() == 'credit';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final dateStr = tx['transactionDate']?.toString().split('T')[0] ?? '';
    DateTime? date = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : dateStr;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(widget.isLight ? 0.03 : 0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            onTap: widget.onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.south_west : Icons.north_east,
                color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                size: 20,
              ),
            ),
            title: Text(tx['userName'] ?? 'Member', style: TextStyle(color: widget.isLight ? const Color(0xFF1E293B) : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(formattedDate, style: TextStyle(color: widget.isLight ? Colors.black26 : Colors.white38, fontSize: 12)),
            trailing: Text(
              '${isCredit ? '+' : '-'} ₹${NumberFormat("#,##0", "en_IN").format(amount)}',
              style: TextStyle(
                color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

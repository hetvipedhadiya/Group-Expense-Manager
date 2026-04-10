import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:grocery/Person_Api.dart';
import 'package:grocery/TransactionAPI.dart';
import 'package:grocery/TransactionForm.dart';

class DashboardScreen extends StatefulWidget {
  final int eventId;
  final String eventName;
  DashboardScreen({required this.eventId, required this.eventName});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<List<dynamic>>? _transactionFuture;
  List<dynamic> _personsFuture = [];

  @override
  void initState() {
    super.initState();
    _fetchEventWisePersons();
    _transactionFuture = _fetchTransactions();
  }

  Future<void> _fetchEventWisePersons() async {
    var persons = await PersonApi().getPersonsByEvent(widget.eventId);
    setState(() {
      _personsFuture = persons;
    });
  }

  Future<List<dynamic>> _fetchTransactions() async {
    return await TransactionAPI().getTransactionByEvent(widget.eventId);
  }

  void _refreshTransactions() {
    setState(() {
      _transactionFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3E4FBD)
        ),
        child: FloatingActionButton(
          onPressed: () {
            if (_personsFuture.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please add a person first!")),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionForm(
                    eventID: widget.eventId,
                    eventName: widget.eventName,
                    map: null,
                  ),
                ),
              ).then((value) {
                if (value == true) _refreshTransactions();
              });
            }
          },
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0, // Remove shadow to blend with gradient
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Transactions Found"));
          } else {
            var transactions = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 20),
                  _buildBalanceCard(transactions),
                  SizedBox(height: 20),
                  _buildTransactionSection(transactions),

                ],
              ),
            );
          }
        },
      ),
    );
  }



  Widget _buildBalanceCard(List<dynamic> transactions) {
    double totalIncome = transactions
        .where((t) => t['transactionType'] == "credit")
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    double totalExpense = transactions
        .where((t) => t['transactionType'] == "debit")
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    double availableBalance = totalIncome - totalExpense;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFF6373D9)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem("Total Income", totalIncome, Colors.white),
              _buildBalanceItem("Total Expense", totalExpense, Colors.white),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.white),
          SizedBox(height: 12),
          _buildBalanceItem("Total Balance", availableBalance, Colors.white, isBold: true),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String title, double amount, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 4),
        Text(
          "₹${NumberFormat("#,##0.00", "en_IN").format(amount)}",
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  Widget _buildTransactionSection(List<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.map((transaction) {
        bool isCredit = transaction['transactionType'] == 'credit';
        double amount = (transaction['amount'] as num).toDouble();
        String formattedAmount = "₹${NumberFormat("#,##0.00", "en_IN").format(amount)}";

        return GestureDetector(
          onTap: () => _showTransactionDialog(transaction),
          child: Container(
            color: Colors.white,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit ? Colors.green : Colors.red,
                  child: Icon(Icons.category, color: Colors.white),
                ),
                title: Text(
                  transaction['userName'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  transaction['transactionDate'].toString().split('T')[0],
                  style: TextStyle(fontSize: 15),
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
          ),
        );
      }).toList(),
    );
  }

  void _showTransactionDialog(dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Transaction Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit'),
                onTap: () async {
                  Navigator.pop(context);
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionForm(
                        eventID: widget.eventId,
                        eventName: widget.eventName,
                        map: transaction,
                      ),
                    ),
                  );
                  if (result == true) _refreshTransactions();
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);

                  // ✅ Check if transaction ID is null before calling delete
                  if (transaction['expenseID'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: Tran/saction ID is missing."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    bool isDeleted = await TransactionAPI().deleteTransaction(transaction['expenseID']);
                    if (isDeleted) {
                      _refreshTransactions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Transaction deleted successfully!"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to delete transaction. Please try again."),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error deleting transaction: ${e.toString()}"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }




}

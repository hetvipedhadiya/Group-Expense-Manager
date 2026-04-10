import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionReportModel {
   int totalMembers;
   double totalIncome;
   double totalExpense;
   double expensePerHead;


  TransactionReportModel({
    required this.totalMembers,
    required this.totalIncome,
    required this.totalExpense,
    required this.expensePerHead,
  });

  // Factory method to create an instance from JSON
  factory TransactionReportModel.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");  // Debugging line

    return TransactionReportModel(
      totalMembers: json['totalMembers'] ?? 0,
      totalIncome: (json['totalIncome'] ?? 0.0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0.0).toDouble(),
      expensePerHead: (json['expensePerHead'] ?? 0.0).toDouble(),
    );
  }


  // // Convert the object back to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return {
      data['totalMembers']: totalMembers,
      data['totalIncome']: totalIncome,
      data['totalExpense']: totalExpense,
      data['expensePerHead']: expensePerHead,
    };
  }

}

class TransactionMemberReportModel {
  String name;
  double Income;
  double Expense;


  TransactionMemberReportModel({
    required this.name,
    required this.Income,
    required this.Expense,
  });

  // Factory method to create an instance from JSON
  factory TransactionMemberReportModel.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");  // Debugging line

    return TransactionMemberReportModel(
      name: json['member'] ?? '',
      Income: (json['income'] ?? 0.0).toDouble(),
      Expense: (json['expense'] ?? 0.0).toDouble(),
    );
  }


  // // Convert the object back to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return {
      data['member']: name,
      data['income']: Income,
      data['expense']: Expense,
    };
  }

}

// class PieData {
//    List<PieChartSectionData> data = [
//     PieChartSectionData(color: Colors.blue, value: 30, title: '30%'),
//     PieChartSectionData(color: Colors.red, value: 40, title: '40%'),
//     PieChartSectionData(color: Colors.green, value: 30, title: '30%'),
//   ];
// }
//
//
// class Data {
//   //final String name;
//
//   final double percent;
//
//   final Color color;
//
//   Data({ required this.percent, required this.color});
// }

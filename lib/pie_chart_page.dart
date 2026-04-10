// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:grocery/pieChartSection.dart';
//
// class PieChartPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => PieChartPageState();
// }
//
// class PieChartPageState extends State<PieChartPage> {
//   int touchedIndex =0;
//
//   @override
//   Widget build(BuildContext context) => Card(
//     child: Column(
//       children: <Widget>[
//         Expanded(
//           child: PieChart(
//             PieChartData(
//               pieTouchData: PieTouchData(
//                   touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
//                     setState(() {
//                       if (pieTouchResponse == null ||
//                           event is FlLongPressEnd ) {
//                         touchedIndex = -1;
//                       } else {
//                         touchedIndex = pieTouchResponse.touchedSection?.touchedSectionIndex ?? -1;
//                       }
//                     });
//                   }
//
//               ),
//               borderData: FlBorderData(show: false),
//               sectionsSpace: 0,
//               centerSpaceRadius: 40,
//               sections: getSections(touchedIndex),
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               //child: IndicatorsWidget(),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
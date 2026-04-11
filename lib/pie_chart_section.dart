// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:grocery/models/transaction_report_model.dart';
//
// List<PieChartSectionData> getSections(int touchedIndex) => PieData().data
//     .asMap()
//     .map<int, PieChartSectionData>((index, data) {
//   final isTouched = index == touchedIndex;
//   final double fontSize = isTouched ? 25 : 16;
//   final double radius = isTouched ? 100 : 80;
//
//   final value = PieChartSectionData(
//     color: data.color,
//     value: data.value,
//     title: '${data.title}%',
//     radius: radius,
//     titleStyle: TextStyle(
//       fontSize: fontSize,
//       fontWeight: FontWeight.bold,
//       color: const Color(0xffffffff),
//     ),
//   );
//
//   return MapEntry(index, value);
// })
//     .values
//     .toList();
//
//
//
//
//
// //
// // class IndicatorsWidget extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Column(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: PieData.data
// //         .map(
// //           (data) => Container(
// //           padding: EdgeInsets.symmetric(vertical: 2),
// //           child: buildIndicator(
// //             color: data.color,
// //             //text: data.name,
// //             // isSquare: true,
// //           )),
// //     )
// //         .toList(),
// //   );
// //
// //   Widget buildIndicator({
// //     required Color color,
// //     required String text,
// //     bool isSquare = false,
// //     double size = 16,
// //     Color textColor = const Color(0xff505050),
// //   }) =>
// //       Row(
// //         children: <Widget>[
// //           Container(
// //             width: size,
// //             height: size,
// //             decoration: BoxDecoration(
// //               shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
// //               color: color,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Text(
// //             text,
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: textColor,
// //             ),
// //           )
// //         ],
// //       );
// // }

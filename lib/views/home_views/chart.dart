// import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 2),
              FlSpot(2, 1.5),
              FlSpot(3, 3),
              FlSpot(4, 2.8),
              FlSpot(5, 3.5),
            ],
            isCurved: true, // Optional: To create a smooth curve
            colors: [Colors.yellow],
            dotData: FlDotData(
              show: true, // To show dots at data points
              // dotColor: Colors.yellow,
            ),
            belowBarData: BarAreaData(show: false), // Disable shaded area
          ),
        ],
        titlesData: FlTitlesData(show: false), // Disable axis titles
        gridData: FlGridData(show: false), // Disable grid
        borderData: FlBorderData(show: false), // Disable borders
      ),
    );
  }
}

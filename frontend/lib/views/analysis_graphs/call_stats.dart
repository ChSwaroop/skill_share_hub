import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:intl/intl.dart';
import 'package:skill_share_hub/models/call_stats_model.dart';

class CallStatsChart extends StatefulWidget {
  final CallStats callStats;
  final bool showAudioStats; // To toggle between audio and video stats

  const CallStatsChart({
    super.key,
    required this.callStats,
    this.showAudioStats = true,
  });

  @override
  State<CallStatsChart> createState() => _CallStatsChartState();
}

class _CallStatsChartState extends State<CallStatsChart> {
  List<Color> gradientColors = [
    ColorsUtil.primaryclr,
    ColorsUtil.secondaryclr,
  ];

  bool showAvg = false;
  late List<DailyStat> sortedStats;
  late double maxY;
  late double minY;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    // Sort the daily stats by date
    sortedStats = [...?widget.callStats.dailyStats];
    sortedStats.sort((a, b) => a.date!.compareTo(b.date!));

    // Calculate max and min counts for Y-axis scaling
    if (sortedStats.isEmpty) {
      maxY = 100;
      minY = 0;
    } else {
      final maxCount = sortedStats
          .map((stat) => widget.showAudioStats
              ? (stat.audio?.count ?? 0)
              : (stat.video?.count ?? 0))
          .reduce((value, element) => value > element ? value : element);

      // Set the max Y value to be slightly higher than the max count for better visualization
      maxY = (maxCount * 1.2).ceilToDouble();
      minY = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 34,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showAvg = !showAvg;
                      });
                    },
                    child: Text(
                      'avg',
                      style: TextStyle(
                        fontSize: 12,
                        color: showAvg
                            ? ColorsUtil.primaryclr
                            : ColorsUtil.primaryclr,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 34,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        widget.showAudioStats ? 'Audio' : 'Video';
                      });
                    },
                    child: Text(
                      widget.showAudioStats ? 'Audio' : 'Video',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorsUtil.primaryclr,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    // Check if there's data and the index is valid
    if (sortedStats.isEmpty ||
        value.toInt() >= sortedStats.length ||
        value.toInt() < 0) {
      return const SizedBox();
    }

    // Format the date to display day format (e.g., "01", "02")
    final date = sortedStats[value.toInt()].date;
    final dayString = date != null ? DateFormat('M/d').format(date) : '';

    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Text(dayString, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value == 0) {
      return const SizedBox();
    }

    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Text(
      '${(value - 1).toInt()}',
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY / 6,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: ColorsUtil.primaryclr.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: ColorsUtil.primaryclr.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: sortedStats.isEmpty ? 7 : (sortedStats.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: sortedStats.isEmpty
              ? [const FlSpot(0, 0)]
              : List.generate(
                  sortedStats.length,
                  (index) => FlSpot(
                      index.toDouble(),
                      ((widget.showAudioStats
                                  ? (sortedStats[index].audio?.count ?? 0)
                                  : (sortedStats[index].video?.count ?? 0)) -
                              1)
                          .toDouble())),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
            getDotPainter: _defaultGetDotPainter,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors.map((color) => color.withAlpha(30)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  static FlDotPainter _defaultGetDotPainter(
    FlSpot spot,
    double xPercentage,
    LineChartBarData bar,
    int index,
  ) {
    return FlDotCirclePainter(
      radius: 3,
      color: bar.gradient?.colors.first ?? bar.color ?? Colors.blueAccent,
      strokeWidth: 1,
      strokeColor: Colors.white,
    );
  }

  LineChartData avgData() {
    // Calculate the average call count
    final avgCallCount = sortedStats.isEmpty
        ? 0.0
        : sortedStats
                .map((stat) => widget.showAudioStats
                    ? (stat.audio?.count ?? 0)
                    : (stat.video?.count ?? 0))
                .reduce((a, b) => a + b) /
            sortedStats.length;

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: maxY / 6,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: sortedStats.isEmpty ? 7 : (sortedStats.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: sortedStats.isEmpty
              ? [const FlSpot(0, 0)]
              : List.generate(sortedStats.length,
                  (index) => FlSpot(index.toDouble(), avgCallCount)),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withAlpha(10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

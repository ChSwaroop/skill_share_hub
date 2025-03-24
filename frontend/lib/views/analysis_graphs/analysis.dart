import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/bar_graph/individual_bar.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/messageStatsModel.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/stats_repo.dart';

// class ItemPrice {
//   final String item;
//   final int price;
//   final String category;

//   ItemPrice({required this.item, required this.price, required this.category});
// }

class UserStats extends StatefulWidget {
  const UserStats({super.key});

  @override
  State<UserStats> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats> {
  List<DailyStat> messageStatsData = [
    // MarketPriceModel(item: "Tomato", price: 25, category: "vegetable"),
    // MarketPriceModel(item: "Onion", price: 8, category: "vegetable"),
    // MarketPriceModel(item: "Apple", price: 100, category: "fruits"),
  ];

  List<IndividualBar> barData = [];
  Map<int, String> itemLabels = {};

  void initializeBarData(MessageStats messagesCount) {
    barData = [];
    itemLabels = {};

    for (int i = 0; i < messagesCount.dailyStats!.length; i++) {
      barData.add(IndividualBar(
          x: i, y: messagesCount.dailyStats![i].messageCount!.toDouble()));
      itemLabels[i] = messagesCount.dailyStats![i].date
          .toString(); // Map x value to item name
    }
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      isLoading = true;
      setState(() {});
      final message_stats = await StatsRepo().getMessageStats(
          Provider.of<UserProvider>(context, listen: false).user!.id!, 7);
      if (message_stats != null) {
        messageStatsData = message_stats.dailyStats!;
        initializeBarData(message_stats);
      } else {
        debugPrint("error: " + message_stats.toString());
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxPrice = messageStatsData.isNotEmpty
        ? messageStatsData
            .map((item) => item.messageCount)
            .reduce((a, b) => a! > b! ? a : b)
            ?.toDouble()
        : 0.0; // Default value when no data is available

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Container(
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Market Prices"),
              Spacer(),
              (isLoading)
                  ? CircularProgressIndicator(
                      color: ColorsUtil.primaryclr,
                    )
                  : SizedBox(
                      height: height / 2,
                      child: BarChart(
                        BarChartData(
                          maxY: ((maxPrice ?? 0) + 30),
                          minY: 5,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(),
                                bottom: BorderSide(),
                              )),
                          barGroups: barData
                              .map(
                                (data) => BarChartGroupData(
                                  x: data.x,
                                  barRods: [
                                    BarChartRodData(
                                      toY: data.y,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(5),
                                      color: ColorsUtil.primaryclr,
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        show: true,
                                        toY: ((maxPrice ?? 0) + 30),
                                        color: ColorsUtil.primaryclr
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      itemLabels[value.toInt()] ?? "",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                        ),
                      ),
                    ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

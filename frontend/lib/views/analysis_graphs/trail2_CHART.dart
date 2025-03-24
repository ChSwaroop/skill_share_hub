import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/models/messageStatsModel.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/stats_repo.dart';
import 'package:skill_share_hub/views/analysis_graphs/trail_chart.dart';

class TrailChart extends StatefulWidget {
  const TrailChart({super.key});

  @override
  State<TrailChart> createState() => _TrailChartState();
}

class _TrailChartState extends State<TrailChart> {
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
        // messageStatsData = message_stats.dailyStats!;
        // initializeBarData(message_stats);
        List<DailyStat> stats = message_stats.dailyStats!
            .map((item) => DailyStat(
                date: item.date, messageCount: (item.messageCount! + 1)))
            .toList();

        for (int i = 0; i < stats.length; i++)
          debugPrint("message stats[$i]: " + stats[i].messageCount.toString());
        setState(() {
          messageStats = MessageStats(
            success: true,
            dailyStats: stats,
          );
        });
      } else {
        debugPrint("error: " + message_stats.toString());
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  // Example usage
  var messageStats = MessageStats(
    success: true,
    dailyStats: [
      // DailyStat(date: DateTime(2025, 3, 1), messageCount: 45),
      // DailyStat(date: DateTime(2025, 3, 1), messageCount: 45),
      // DailyStat(date: DateTime(2025, 3, 1), messageCount: 45),
      // DailyStat(date: DateTime(2025, 3, 2), messageCount: 52),
      // DailyStat(date: DateTime(2025, 3, 2), messageCount: 52),
      // DailyStat(date: DateTime(2025, 3, 2), messageCount: 52),
      // DailyStat(date: DateTime(2025, 3, 3), messageCount: 38),
      // DailyStat(date: DateTime(2025, 3, 3), messageCount: 38),
      // DailyStat(date: DateTime(2025, 3, 3), messageCount: 38),
      // // Add more daily stats...
    ],
    total: 135,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Statistics')),
      body: (isLoading)
          ? CircularProgressIndicator()
          : MessageStatsChart(messageStats: messageStats),
    );
  }
}

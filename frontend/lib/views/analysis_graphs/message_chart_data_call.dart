import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/models/call_stats_model.dart' as callModel;
import 'package:skill_share_hub/models/call_stats_model.dart';
import 'package:skill_share_hub/models/messageStatsModel.dart' as messageModel;
import 'package:skill_share_hub/models/messageStatsModel.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/stats_repo.dart';
import 'package:skill_share_hub/views/analysis_graphs/call_chart_data_call.dart';
import 'package:skill_share_hub/views/analysis_graphs/call_stats.dart';
import 'package:skill_share_hub/views/analysis_graphs/message_stats_chart.dart';

class TrailChart extends StatefulWidget {
  const TrailChart({super.key});

  @override
  State<TrailChart> createState() => _TrailChartState();
}

class _TrailChartState extends State<TrailChart> {
  bool isLoading = true;

  var callStats = CallStats(
    success: true,
    dailyStats: [],
  );

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
        List<messageModel.DailyStat> stats = message_stats.dailyStats!
            .map((item) => messageModel.DailyStat(
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

      final call_stats = await StatsRepo().getCallStats(
          Provider.of<UserProvider>(context, listen: false).user!.id!, 7);
      if (call_stats != null) {
        // messageStatsData = message_stats.dailyStats!;
        // initializeBarData(message_stats);
        List<callModel.DailyStat> stats = call_stats.dailyStats!
            .map(
              (item) => callModel.DailyStat(
                date: item.date,
                audio: Audio(
                    duration: (item.audio!.duration! + 1),
                    count: (item.audio!.duration! + 1)),
                video: Audio(
                  duration: (item.audio!.duration! + 1),
                  count: (item.audio!.duration! + 1),
                ),
              ),
            )
            .toList();

        for (int i = 0; i < stats.length; i++)
          // debugPrint("call stats[$i]: " + stats[i]..toString());
          setState(() {
            callStats = CallStats(
              success: true,
              dailyStats: stats,
            );
          });
      } else {
        debugPrint("error: " + call_stats.toString());
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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(title: const Text('Message Statistics')),
        body: (isLoading)
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        height: height / 2,
                        child: MessageStatsChart(messageStats: messageStats)),
                    SizedBox(height: 50),
                    SizedBox(
                      height: height / 2,
                      child: CallStatsChart(
                        callStats: callStats,
                        showAudioStats:
                            true, // Set to false to show video stats
                      ),
                    ),
                  ],
                ),
              ));
  }
}

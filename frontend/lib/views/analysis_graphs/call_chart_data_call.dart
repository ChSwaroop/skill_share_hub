import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/models/call_stats_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/stats_repo.dart';
import 'package:skill_share_hub/views/analysis_graphs/call_stats.dart';

class CallStatsData extends StatefulWidget {
  const CallStatsData({super.key});

  @override
  State<CallStatsData> createState() => _CallStatsDataState();
}

class _CallStatsDataState extends State<CallStatsData> {
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
      final call_stats = await StatsRepo().getCallStats(
          Provider.of<UserProvider>(context, listen: false).user!.id!, 7);
      if (call_stats != null) {
        // messageStatsData = message_stats.dailyStats!;
        // initializeBarData(message_stats);
        List<DailyStat> stats = call_stats.dailyStats!
            .map((item) => DailyStat(
                date: item.date, audio: item.audio, video: item.video))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CallStatsChart(
        callStats: callStats,
        showAudioStats: true, // Set to false to show video stats
      ),
    );
  }
}

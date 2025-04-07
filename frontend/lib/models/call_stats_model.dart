// To parse this JSON data, do
//
//     final callStats = callStatsFromJson(jsonString);

import 'dart:convert';

CallStats callStatsFromJson(String str) => CallStats.fromJson(json.decode(str));

String callStatsToJson(CallStats data) => json.encode(data.toJson());

class CallStats {
  bool? success;
  List<DailyStat>? dailyStats;
  Totals? totals;

  CallStats({
    this.success,
    this.dailyStats,
    this.totals,
  });

  factory CallStats.fromJson(Map<String, dynamic> json) => CallStats(
        success: json["success"],
        dailyStats: json["dailyStats"] == null
            ? []
            : List<DailyStat>.from(
                json["dailyStats"]!.map((x) => DailyStat.fromJson(x))),
        totals: json["totals"] == null ? null : Totals.fromJson(json["totals"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "dailyStats": dailyStats == null
            ? []
            : List<dynamic>.from(dailyStats!.map((x) => x.toJson())),
        "totals": totals?.toJson(),
      };
}

class DailyStat {
  DateTime? date;
  Audio? audio;
  Audio? video;

  DailyStat({
    this.date,
    this.audio,
    this.video,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) => DailyStat(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        audio: json["audio"] == null ? null : Audio.fromJson(json["audio"]),
        video: json["video"] == null ? null : Audio.fromJson(json["video"]),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "audio": audio?.toJson(),
        "video": video?.toJson(),
      };
}

class Audio {
  int? duration;
  int? count;

  Audio({
    this.duration,
    this.count,
  });

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
        duration: json["duration"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "duration": duration,
        "count": count,
      };
}

class Totals {
  int? audioDuration;
  int? audioCount;
  int? videoDuration;
  int? videoCount;

  Totals({
    this.audioDuration,
    this.audioCount,
    this.videoDuration,
    this.videoCount,
  });

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
        audioDuration: json["audioDuration"],
        audioCount: json["audioCount"],
        videoDuration: json["videoDuration"],
        videoCount: json["videoCount"],
      );

  Map<String, dynamic> toJson() => {
        "audioDuration": audioDuration,
        "audioCount": audioCount,
        "videoDuration": videoDuration,
        "videoCount": videoCount,
      };
}

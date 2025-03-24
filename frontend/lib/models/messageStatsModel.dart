// To parse this JSON data, do
//
//     final messageStats = messageStatsFromJson(jsonString);

import 'dart:convert';

MessageStats messageStatsFromJson(String str) =>
    MessageStats.fromJson(json.decode(str));

String messageStatsToJson(MessageStats data) => json.encode(data.toJson());

class MessageStats {
  bool? success;
  List<DailyStat>? dailyStats;
  int? total;

  MessageStats({
    this.success,
    this.dailyStats,
    this.total,
  });

  factory MessageStats.fromJson(Map<String, dynamic> json) => MessageStats(
        success: json["success"],
        dailyStats: json["dailyStats"] == null
            ? []
            : List<DailyStat>.from(
                json["dailyStats"]!.map((x) => DailyStat.fromJson(x))),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "dailyStats": dailyStats == null
            ? []
            : List<dynamic>.from(dailyStats!.map((x) => x.toJson())),
        "total": total,
      };
}

class DailyStat {
  DateTime? date;
  int? messageCount;

  DailyStat({
    this.date,
    this.messageCount,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) => DailyStat(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        messageCount: json["messageCount"],
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "messageCount": messageCount,
      };
}

// To parse this JSON data, do
//
//     final todo = todoFromJson(jsonString);

import 'dart:convert';

Todo todoFromJson(String str) => Todo.fromJson(json.decode(str));

String todoToJson(Todo data) => json.encode(data.toJson());

class Todo {
  bool? success;
  int? count;
  List<Datum>? data;

  Todo({
    this.success,
    this.count,
    this.data,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        success: json["success"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "count": count,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  NotificationSent? notificationSent;
  String? id;
  String? user;
  String? title;
  String? description;
  bool? completed;
  DateTime? dueDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.notificationSent,
    this.id,
    this.user,
    this.title,
    this.description,
    this.completed,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        notificationSent: json["notificationSent"] == null
            ? null
            : NotificationSent.fromJson(json["notificationSent"]),
        id: json["_id"],
        user: json["user"],
        title: json["title"],
        description: json["description"],
        completed: json["completed"],
        dueDate:
            json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "notificationSent": notificationSent?.toJson(),
        "_id": id,
        "user": user,
        "title": title,
        "description": description,
        "completed": completed,
        "dueDate": dueDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class NotificationSent {
  bool? fifteenMin;
  bool? fiveMin;

  NotificationSent({
    this.fifteenMin,
    this.fiveMin,
  });

  factory NotificationSent.fromJson(Map<String, dynamic> json) =>
      NotificationSent(
        fifteenMin: json["fifteenMin"],
        fiveMin: json["fiveMin"],
      );

  Map<String, dynamic> toJson() => {
        "fifteenMin": fifteenMin,
        "fiveMin": fiveMin,
      };
}

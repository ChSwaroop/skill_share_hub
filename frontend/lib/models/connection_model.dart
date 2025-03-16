// To parse this JSON data, do
//
//     final connection = connectionFromJson(jsonString);

import 'dart:convert';

Connection connectionFromJson(String str) =>
    Connection.fromJson(json.decode(str));

String connectionToJson(Connection data) => json.encode(data.toJson());

class Connection {
  bool? success;
  int? count;
  int? total;
  int? totalPages;
  int? currentPage;
  String? userId;
  List<Datum>? data;

  Connection({
    this.success,
    this.count,
    this.total,
    this.totalPages,
    this.currentPage,
    this.userId,
    this.data,
  });

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        success: json["success"],
        count: json["count"],
        total: json["total"],
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
        userId: json["userId"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "count": count,
        "total": total,
        "totalPages": totalPages,
        "currentPage": currentPage,
        "userId": userId,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  Id? requesterId;
  Id? recipientId;
  String? status;
  dynamic message;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? totalMessageCount;
  int? totalAudioCallDuration;
  int? totalVideoCallDuration;
  int? v;

  Datum({
    this.id,
    this.requesterId,
    this.recipientId,
    this.status,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.totalMessageCount,
    this.totalAudioCallDuration,
    this.totalVideoCallDuration,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        requesterId: json["requesterId"] == null
            ? null
            : Id.fromJson(json["requesterId"]),
        recipientId: json["recipientId"] == null
            ? null
            : Id.fromJson(json["recipientId"]),
        status: json["status"],
        message: json["message"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        totalMessageCount: json["totalMessageCount"],
        totalAudioCallDuration: json["totalAudioCallDuration"],
        totalVideoCallDuration: json["totalVideoCallDuration"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "requesterId": requesterId?.toJson(),
        "recipientId": recipientId?.toJson(),
        "status": status,
        "message": message,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "totalMessageCount": totalMessageCount,
        "totalAudioCallDuration": totalAudioCallDuration,
        "totalVideoCallDuration": totalVideoCallDuration,
        "__v": v,
      };
}

class Id {
  String? id;
  String? username;
  String? profilePicture;

  Id({
    this.id,
    this.username,
    this.profilePicture,
  });

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        id: json["_id"],
        username: json["username"],
        profilePicture: json["profilePicture"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "profilePicture": profilePicture,
      };
}

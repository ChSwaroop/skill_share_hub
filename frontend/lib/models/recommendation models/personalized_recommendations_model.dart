// To parse this JSON data, do
//
//     final personalizedRecommendation = personalizedRecommendationFromJson(jsonString);

import 'dart:convert';

PersonalizedRecommendation personalizedRecommendationFromJson(String str) =>
    PersonalizedRecommendation.fromJson(json.decode(str));

String personalizedRecommendationToJson(PersonalizedRecommendation data) =>
    json.encode(data.toJson());

class PersonalizedRecommendation {
  bool? success;
  int? count;
  List<Datum>? data;

  PersonalizedRecommendation({
    this.success,
    this.count,
    this.data,
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      PersonalizedRecommendation(
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
  String? id;
  String? name;
  DateTime? createdAt;
  int? v;
  double? recommendationScore;
  String? recommendationReason;
  dynamic progress;
  List<Expert>? experts;
  int? totalExperts;

  Datum({
    this.id,
    this.name,
    this.createdAt,
    this.v,
    this.recommendationScore,
    this.recommendationReason,
    this.progress,
    this.experts,
    this.totalExperts,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        name: json["name"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        v: json["__v"],
        recommendationScore: json["recommendationScore"]?.toDouble(),
        recommendationReason: json["recommendationReason"],
        progress: json["progress"],
        experts: json["experts"] == null
            ? []
            : List<Expert>.from(
                json["experts"]!.map((x) => Expert.fromJson(x))),
        totalExperts: json["totalExperts"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
        "recommendationScore": recommendationScore,
        "recommendationReason": recommendationReason,
        "progress": progress,
        "experts": experts == null
            ? []
            : List<dynamic>.from(experts!.map((x) => x.toJson())),
        "totalExperts": totalExperts,
      };
}

class Expert {
  String? id;
  String? username;
  String? firstName;
  String? lastName;
  List<Skill>? skills;
  String? profilePicture;

  Expert({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.skills,
    this.profilePicture,
  });

  factory Expert.fromJson(Map<String, dynamic> json) => Expert(
        id: json["_id"],
        username: json["username"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        skills: json["skills"] == null
            ? []
            : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
        profilePicture: json["profilePicture"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        "skills": skills == null
            ? []
            : List<dynamic>.from(skills!.map((x) => x.toJson())),
        "profilePicture": profilePicture,
      };
}

class Skill {
  String? id;
  String? name;

  Skill({
    this.id,
    this.name,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

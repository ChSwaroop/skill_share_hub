// To parse this JSON data, do
//
//     final userSearchModel = userSearchModelFromJson(jsonString);

import 'dart:convert';

UserSearchModel userSearchModelFromJson(String str) =>
    UserSearchModel.fromJson(json.decode(str));

String userSearchModelToJson(UserSearchModel data) =>
    json.encode(data.toJson());

class UserSearchModel {
  String? message;
  List<User>? users;

  UserSearchModel({
    this.message,
    this.users,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) =>
      UserSearchModel(
        message: json["message"],
        users: json["users"] == null
            ? []
            : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "users": users == null
            ? []
            : List<dynamic>.from(users!.map((x) => x.toJson())),
      };
}

class User {
  String? id;
  String? username;
  String? firstName;
  String? lastName;
  String? dateOfBirth;
  String? gender;
  String? email;
  String? phoneNumber;
  String? password;
  List<Education>? education;
  List<Experience>? workExperience;
  List<Experience>? internshipExperience;
  List<Skill>? skills;
  List<dynamic>? certifications;
  String? profilePicture;
  String? bio;
  List<dynamic>? blockedUsers;
  DateTime? createdAt;
  int? v;

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phoneNumber,
    this.password,
    this.education,
    this.workExperience,
    this.internshipExperience,
    this.skills,
    this.certifications,
    this.profilePicture,
    this.bio,
    this.blockedUsers,
    this.createdAt,
    this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        username: json["username"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        dateOfBirth: json["dateOfBirth"],
        gender: json["gender"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        password: json["password"],
        education: json["education"] == null
            ? []
            : List<Education>.from(
                json["education"]!.map((x) => Education.fromJson(x))),
        workExperience: json["workExperience"] == null
            ? []
            : List<Experience>.from(
                json["workExperience"]!.map((x) => Experience.fromJson(x))),
        internshipExperience: json["internshipExperience"] == null
            ? []
            : List<Experience>.from(json["internshipExperience"]!
                .map((x) => Experience.fromJson(x))),
        skills: json["skills"] == null
            ? []
            : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
        certifications: json["certifications"] == null
            ? []
            : List<dynamic>.from(json["certifications"]!.map((x) => x)),
        profilePicture: json["profilePicture"],
        bio: json["bio"],
        blockedUsers: json["blockedUsers"] == null
            ? []
            : List<dynamic>.from(json["blockedUsers"]!.map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        "dateOfBirth": dateOfBirth,
        "gender": gender,
        "email": email,
        "phoneNumber": phoneNumber,
        "password": password,
        "education": education == null
            ? []
            : List<dynamic>.from(education!.map((x) => x.toJson())),
        "workExperience": workExperience == null
            ? []
            : List<dynamic>.from(workExperience!.map((x) => x.toJson())),
        "internshipExperience": internshipExperience == null
            ? []
            : List<dynamic>.from(internshipExperience!.map((x) => x.toJson())),
        "skills": skills == null
            ? []
            : List<dynamic>.from(skills!.map((x) => x.toJson())),
        "certifications": certifications == null
            ? []
            : List<dynamic>.from(certifications!.map((x) => x)),
        "profilePicture": profilePicture,
        "bio": bio,
        "blockedUsers": blockedUsers == null
            ? []
            : List<dynamic>.from(blockedUsers!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}

class Education {
  String? level;
  String? startDate;
  String? endDate;
  String? id;

  Education({
    this.level,
    this.startDate,
    this.endDate,
    this.id,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        level: json["level"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "level": level,
        "startDate": startDate,
        "endDate": endDate,
        "_id": id,
      };
}

class Experience {
  String? role;
  String? id;

  Experience({
    this.role,
    this.id,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        role: json["role"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "role": role,
        "_id": id,
      };
}

class Skill {
  String? id;
  String? name;
  DateTime? createdAt;
  int? v;

  Skill({
    this.id,
    this.name,
    this.createdAt,
    this.v,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json["_id"],
        name: json["name"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}

// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? message;
  String? token;
  User? user;

  LoginModel({
    this.message,
    this.token,
    this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        message: json["message"],
        token: json["token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
        "user": user?.toJson(),
      };
}

class User {
  String? id;
  String? username;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  String? email;
  String? phoneNumber;
  String? password;
  List<Education>? education;
  List<Experience>? workExperience;
  List<Experience>? internshipExperience;
  List<String>? skills;
  List<dynamic>? certifications;
  List<dynamic>? connections;
  List<dynamic>? pendingConnections;
  DateTime? lastSeen;
  bool? isOnline;
  List<dynamic>? blockedUsers;
  String? profilePicture;
  String? bio;
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
    this.connections,
    this.pendingConnections,
    this.lastSeen,
    this.isOnline,
    this.blockedUsers,
    this.profilePicture,
    this.bio,
    this.createdAt,
    this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        username: json["username"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        dateOfBirth: json["dateOfBirth"] == null
            ? null
            : DateTime.parse(json["dateOfBirth"]),
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
            : List<String>.from(json["skills"]!.map((x) => x)),
        certifications: json["certifications"] == null
            ? []
            : List<dynamic>.from(json["certifications"]!.map((x) => x)),
        connections: json["connections"] == null
            ? []
            : List<dynamic>.from(json["connections"]!.map((x) => x)),
        pendingConnections: json["pendingConnections"] == null
            ? []
            : List<dynamic>.from(json["pendingConnections"]!.map((x) => x)),
        lastSeen:
            json["lastSeen"] == null ? null : DateTime.parse(json["lastSeen"]),
        isOnline: json["isOnline"],
        blockedUsers: json["blockedUsers"] == null
            ? []
            : List<dynamic>.from(json["blockedUsers"]!.map((x) => x)),
        profilePicture: json["profilePicture"],
        bio: json["bio"],
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
        "dateOfBirth": dateOfBirth?.toIso8601String(),
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
        "skills":
            skills == null ? [] : List<dynamic>.from(skills!.map((x) => x)),
        "certifications": certifications == null
            ? []
            : List<dynamic>.from(certifications!.map((x) => x)),
        "connections": connections == null
            ? []
            : List<dynamic>.from(connections!.map((x) => x)),
        "pendingConnections": pendingConnections == null
            ? []
            : List<dynamic>.from(pendingConnections!.map((x) => x)),
        "lastSeen": lastSeen?.toIso8601String(),
        "isOnline": isOnline,
        "blockedUsers": blockedUsers == null
            ? []
            : List<dynamic>.from(blockedUsers!.map((x) => x)),
        "profilePicture": profilePicture,
        "bio": bio,
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

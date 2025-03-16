// models/message.dart
import 'package:skill_share_hub/models/login_model.dart';

class Message {
  final String id;
  final String chatId;
  final User sender;
  final String content;
  final String contentType;
  final String? fileUrl;
  final String status;
  final List<ReadReceipt> readBy;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.contentType,
    this.fileUrl,
    required this.status,
    required this.readBy,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      chatId: json['chatId'],
      sender: User.fromJson(json['sender']),
      content: json['content'],
      contentType: json['contentType'],
      fileUrl: json['fileUrl'],
      status: json['status'],
      readBy: json['readBy'] != null
          ? (json['readBy'] as List)
              .map((r) => ReadReceipt.fromJson(r))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReadReceipt {
  final String userId;
  final DateTime readAt;

  ReadReceipt({
    required this.userId,
    required this.readAt,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      userId: json['user'],
      readAt: DateTime.parse(json['readAt']),
    );
  }
}

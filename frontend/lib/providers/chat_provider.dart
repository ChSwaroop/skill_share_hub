// providers/chat_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/chat_model.dart';
import 'package:skill_share_hub/models/login_model.dart';
import 'package:skill_share_hub/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatProvider with ChangeNotifier {
  String? _userId;
  IO.Socket? _socket;
  List<Chat> _chats = [];
  Map<String, List<Message>> _messages = {};
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  List<Chat> get chats => _chats;
  Map<String, List<Message>> get messages => _messages;

  // Singleton instance
  static final ChatProvider _instance = ChatProvider._internal();

  factory ChatProvider() {
    return _instance;
  }

  ChatProvider._internal();

  // Initialize socket connection
  void initSocket(String userId) {
    // Only initialize if not already connected with the same user
    debugPrint(_isConnected.toString());
    debugPrint(_userId.toString());
    debugPrint(userId.toString());
    debugPrint(_socket.toString());
    if (_isConnected && _userId == userId && _socket != null) {
      print('Socket already connected for user: $userId');
      return;
    }

    // _userId = userId;
    _userId = userId;

    // Close existing socket if any
    disconnect();

    // Connect to socket server
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Socket event handlers
    _socket!.on('connect', (_) {
      print('Socket connected');
      _isConnected = true;
      debugPrint("sockte is connecte: " + _socket!.connected.toString());
      debugPrint("called auth and connect: " + _socket.hashCode.toString());

      // Authenticate user
      _socket!.emit('authenticate', userId);

      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      print('Socket disconnected');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.on('error', (error) {
      print('Socket error: $error');
    });

    // Handle incoming messages
    _socket!.on('new_message', (data) {
      final message = Message.fromJson(data);
      if (_messages.containsKey(message.chatId)) {
        _messages[message.chatId]!.add(message);
      } else {
        _messages[message.chatId] = [message];
      }

      // Update chat's last message
      final chatIndex = _chats.indexWhere((chat) => chat.id == message.chatId);
      if (chatIndex != -1) {
        final updatedChat = Chat(
          id: _chats[chatIndex].id,
          chatType: _chats[chatIndex].chatType,
          participants: _chats[chatIndex].participants,
          name: _chats[chatIndex].name,
          createdBy: _chats[chatIndex].createdBy,
          admins: _chats[chatIndex].admins,
          lastMessage: message,
          createdAt: _chats[chatIndex].createdAt,
          updatedAt: DateTime.now(),
        );

        _chats[chatIndex] = updatedChat;

        // Sort chats by most recent message
        _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }

      // If message is received and user is in chat, mark as read
      if (message.sender.id != _userId) {
        _markAsRead(message.id);
      }

      notifyListeners();
    });

    // Handle message status updates
    _socket!.on('message_status_updated', (data) {
      final messageId = data['messageId'];
      final newStatus = data['status'];
      final readBy = data['readBy'];

      // Find and update message status
      for (final chatId in _messages.keys) {
        final index = _messages[chatId]!.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final message = _messages[chatId]![index];

          // Create updated message with new status
          final updatedMessage = Message(
            id: message.id,
            chatId: message.chatId,
            sender: message.sender,
            content: message.content,
            contentType: message.contentType,
            fileUrl: message.fileUrl,
            status: newStatus,
            readBy: newStatus == 'read' && readBy != null
                ? [
                    ...message.readBy,
                    ReadReceipt(userId: readBy, readAt: DateTime.now())
                  ]
                : message.readBy,
            createdAt: message.createdAt,
          );

          _messages[chatId]![index] = updatedMessage;

          // Update last message if this is the most recent
          final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
          if (chatIndex != -1 &&
              _chats[chatIndex].lastMessage?.id == messageId) {
            final updatedChat = Chat(
              id: _chats[chatIndex].id,
              chatType: _chats[chatIndex].chatType,
              participants: _chats[chatIndex].participants,
              name: _chats[chatIndex].name,
              createdBy: _chats[chatIndex].createdBy,
              admins: _chats[chatIndex].admins,
              lastMessage: updatedMessage,
              createdAt: _chats[chatIndex].createdAt,
              updatedAt: _chats[chatIndex].updatedAt,
            );

            _chats[chatIndex] = updatedChat;
          }

          notifyListeners();
          break;
        }
      }
    });

    // Handle user status changes
    _socket!.on('user_status_changed', (data) {
      final userId = data['userId'];
      final status = data['status'];
      final lastSeen = data['lastSeen'] != null
          ? DateTime.parse(data['lastSeen'])
          : DateTime.now();

      // Update user status in all chats
      for (int i = 0; i < _chats.length; i++) {
        final participantIndex =
            _chats[i].participants.indexWhere((p) => p.id == userId);
        if (participantIndex != -1) {
          final participant = _chats[i].participants[participantIndex];
          final updatedParticipant = User(
            id: participant.id,
            username: participant.username,
            email: participant.email,
            profilePicture: participant.profilePicture,
            skills: participant.skills,
            bio: participant.bio,
            connections: participant.connections,
            pendingConnections: participant.pendingConnections,
            lastSeen: lastSeen,
            isOnline: status == 'online',
          );

          final updatedParticipants = List<User>.from(_chats[i].participants);
          updatedParticipants[participantIndex] = updatedParticipant;

          _chats[i] = Chat(
            id: _chats[i].id,
            chatType: _chats[i].chatType,
            participants: updatedParticipants,
            name: _chats[i].name,
            createdBy: _chats[i].createdBy,
            admins: _chats[i].admins,
            lastMessage: _chats[i].lastMessage,
            createdAt: _chats[i].createdAt,
            updatedAt: _chats[i].updatedAt,
          );
        }
      }

      notifyListeners();
    });

    // Handle connection requests
    _socket!.on('connection_request', (data) {
      // Show notification to user about new connection request
      print('New connection request from: ${data['userId']}');
      // This would trigger a UI notification
      notifyListeners();
    });

    // Handle connection accepted
    _socket!.on('connection_accepted', (data) {
      // Refresh user connections
      print('Connection accepted with: ${data['userId']}');
      // Refresh chats list as a new direct chat might have been created
      fetchChats();
    });

    // Handle being added to group
    _socket!.on('added_to_group', (data) {
      print('Added to group: ${data['chatName']}');
      // Refresh chats to include the new group
      fetchChats();
    });

    _socket!.connect();
  }

  // Disconnect socket
  void disconnect() {
    debugPrint("Called to disconnect socket");
    if (_socket != null && _socket!.connected) {
      // Remove all event listeners first
      _socket!.off('connect');
      _socket!.off('disconnect');
      _socket!.off('error');
      _socket!.off('new_message');
      _socket!.off('message_status_updated');
      _socket!.off('user_status_changed');

      debugPrint("already socket exists disconnecting.........");
      debugPrint(_socket.hashCode.toString());
      _socket!.disconnect();
      _socket!.destroy();
      _socket = null;
      _isConnected = false;
    }
  }

  // Fetch user's chats
  Future<void> fetchChats() async {
    if (_userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/api/chats/$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatsJson = json.decode(response.body);
        _chats = chatsJson.map((json) => Chat.fromJson(json)).toList();

        // Sort chats by most recent message
        _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        notifyListeners();
      } else {
        print('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      rethrow;
    }
  }

  // Fetch messages for a specific chat
  Future<void> fetchMessages(String chatId,
      {int page = 1, int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/api/messages/$chatId?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final messages =
            messagesJson.map((json) => Message.fromJson(json)).toList();

        if (_messages.containsKey(chatId)) {
          if (page == 1) {
            // First page, replace existing messages
            _messages[chatId] = messages;
          } else {
            // Subsequent pages, prepend older messages
            _messages[chatId] = [...messages, ..._messages[chatId]!];
          }
        } else {
          _messages[chatId] = messages;
        }

        // Mark received messages as read if they're not from the current user
        for (final message in messages) {
          if (message.sender.id != _userId && message.status != 'read') {
            _markAsRead(message.id);
          }
        }

        notifyListeners();
      } else {
        print('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // Send a new message
  void sendMessage(String chatId, String content,
      {String contentType = 'text', String? fileUrl}) {
    if (!_isConnected || _socket == null) {
      print('Socket not connected. Cannot send message.');
      return;
    }

    _socket!.emit('send_message', {
      'chatId': chatId,
      'content': content,
      'contentType': contentType,
      'fileUrl': fileUrl,
    });
  }

  // Mark a message as read
  void _markAsRead(String messageId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('mark_as_read', {
      'messageId': messageId,
    });
  }

  // Request a connection with another user
  void requestConnection(String targetUserId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('request_connection', {
      'targetUserId': targetUserId,
    });
  }

  // Accept a connection request
  void acceptConnection(String targetUserId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('accept_connection', {
      'targetUserId': targetUserId,
    });
  }

  // Create a new group chat
  void createGroupChat(String name, List<String> participantIds) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('create_group_chat', {
      'name': name,
      'participants': participantIds,
    });
  }
}

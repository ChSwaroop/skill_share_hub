// screens/chat_list_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/chat_model.dart';
import 'package:skill_share_hub/models/login_model.dart';
import 'package:skill_share_hub/providers/chat_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/views/chat_views/chat_screen.dart';
import 'package:skill_share_hub/views/chat_views/group_screen.dart';
import 'package:skill_share_hub/views/home_views/connections.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize socket and fetch chats
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      if (authProvider.token != null && authProvider.user != null) {
        chatProvider.initSocket(authProvider.user!.id!);
        chatProvider.fetchChats();
      }
    });
  }

  void _showConnectionsDialog(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => FutureBuilder(
        future: http.get(
          Uri.parse(
              '${baseUrl}/api/users/${authProvider.user!.id}/connections'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authProvider.token}'
          },
        ),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Failed to load connections'));
          }

          final connections = json.decode(snapshot.data!.body) as List;

          return connections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No connections yet'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectionsPage(
                                authToken: authProvider.token!,
                              ),
                            ),
                          );
                        },
                        child: const Text('Find People'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (ctx, i) {
                    final user = User.fromJson(connections[i]);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(user.profilePicture ?? ''),
                      ),
                      title: Text(user.username ?? ''),
                      subtitle: Text(user.isOnline! ? 'Online' : 'Offline'),
                      onTap: () async {
                        // Check if chat already exists with this user
                        // var existingChat;
                        // existingChat = chatProvider.chats.firstWhere(
                        //   (chat) =>
                        //       chat.chatType == 'direct' &&
                        //       chat.participants.any((p) => p.id == user.id),
                        //   orElse: () => null,
                        // );

                        // if (existingChat != null) {
                        // Open existing chat
                        // Navigator.pop(ctx);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         ChatScreen(chat: existingChat),
                        //   ),
                        // );
                        // } else {
                        // Create new chat
                        try {
                          final response = await http.post(
                            Uri.parse('${baseUrl}/api/chats'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer ${authProvider.token}'
                            },
                            body: json.encode({
                              'chatType': 'direct',
                              'participants': [authProvider.user!.id, user.id],
                            }),
                          );

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            final body = json.decode(response.body);
                            final newChat = Chat.fromJson(body.data);
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(chat: newChat),
                              ),
                            );
                            // Refresh chat list
                            chatProvider.fetchChats();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to create chat: $e')),
                          );
                        }
                        // }
                      },
                    );
                  },
                );
        },
      ),
    );
  }

  @override
  void dispose() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<UserProvider>(context);

    if (!(authProvider.token != null && authProvider.user != null)) {
      return const Center(child: Text('Please login to view chats'));
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (cal) {
        if (cal) chatProvider.disconnect();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnectionsPage(
                      authToken: authProvider.token!,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: chatProvider.chats.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No chats yet'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showConnectionsDialog(context);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Start a new chat'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => chatProvider.fetchChats(),
                child: ListView.builder(
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    final chatName = chat.getChatName(authProvider.user!.id!);
                    final lastMessage = chat.lastMessage;

                    // Find the other user in direct chats for online status
                    bool isOnline = false;
                    if (chat.chatType == 'direct') {
                      final otherUser = chat.participants.firstWhere(
                        (user) => user.id != authProvider.user!.id,
                        orElse: () => chat.participants.first,
                      );
                      isOnline = otherUser.isOnline!;
                    }

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              chat.getChatImage(authProvider.user!.id!),
                            ),
                          ),
                          if (isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(chatName),
                      subtitle: lastMessage != null
                          ? Text(
                              lastMessage.sender.id == authProvider.user!.id
                                  ? 'You: ${lastMessage.content}'
                                  : lastMessage.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              chat.chatType == 'direct'
                                  ? 'Start chatting'
                                  : 'New group',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                      trailing: lastMessage != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timeago.format(lastMessage.createdAt,
                                      locale: 'en_short'),
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                if (lastMessage.sender.id !=
                                    authProvider.user!.id)
                                  _buildStatusIndicator(lastMessage.status)
                              ],
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(chat: chat),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showConnectionsDialog(context);
          },
          child: const Icon(Icons.chat),
          tooltip: 'New Chat',
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    switch (status) {
      case 'sent':
        return Icon(Icons.done, size: 16, color: Colors.grey);
      case 'delivered':
        return Icon(Icons.done_all, size: 16, color: Colors.grey);
      case 'read':
        return Icon(Icons.done_all, size: 16, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }
}

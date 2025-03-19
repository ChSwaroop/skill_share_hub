// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/chat_model.dart';
import 'package:skill_share_hub/providers/chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';
import 'package:skill_share_hub/repo/call_repo.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  final CallRepo _callService = CallRepo(
    agoraService: AgoraRepo(baseUrl: baseUrl),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();

      // Set up scroll listener for pagination
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == 0 && !_isLoading) {
          _loadMoreMessages();
        }
      });
    });
  }

  void _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.fetchMessages(widget.chat.id);

    setState(() {
      _isLoading = false;
    });

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _loadMoreMessages() async {
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.fetchMessages(widget.chat.id, page: _currentPage);

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(widget.chat.id, message);

    _messageController.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final userId = authProvider.user!.id;
    final messages = chatProvider.messages[widget.chat.id] ?? [];

    // Find the other user in direct chats for online status
    bool isOnline = false;
    String subtitle = '';
    if (widget.chat.chatType == 'direct') {
      final otherUser = widget.chat.participants.firstWhere(
        (user) => user.id != userId,
        orElse: () => widget.chat.participants.first,
      );
      isOnline = otherUser.isOnline ?? false;
      subtitle = isOnline
          ? 'Online'
          : 'Last seen ${DateFormat('MMM d, HH:mm').format(otherUser.lastSeen!)}';
    } else {
      // For group chats, show number of members
      subtitle = '${widget.chat.participants.length} members';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.getChatName(userId!)),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _callService.startAudioCall(
              context: context,
              participants: [
                widget.chat.participants[0].id!,
                widget.chat.participants[1].id!
              ],
              displayName: authProvider.user!.username!,
            ),
          ),
          // Video call button
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _callService.startVideoCall(
              context: context,
              // participants: [userId],
              participants: [
                widget.chat.participants[0].id!,
                widget.chat.participants[1].id!
              ],
              displayName: authProvider.user!.username!,
            ),
          ),
        ],
        // subtitle: Text(subtitle),
      ),
      body: Column(
        children: [
          // Loading indicator for pagination
          if (_isLoading) LinearProgressIndicator(),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false, // Display newest at bottom
                    itemCount: messages.length,
                    itemBuilder: (ctx, index) {
                      final message = messages[index];
                      final isMe = message.sender.id == userId;

                      // Group messages by date
                      bool showDate = false;
                      if (index == 0) {
                        showDate = true;
                      } else {
                        final prevMessage = messages[index - 1];
                        final prevDate = DateFormat('yyyy-MM-dd')
                            .format(prevMessage.createdAt);
                        final currDate =
                            DateFormat('yyyy-MM-dd').format(message.createdAt);
                        showDate = prevDate != currDate;
                      }

                      return Column(
                        children: [
                          // Date header
                          if (showDate)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                DateFormat('MMMM d, yyyy')
                                    .format(message.createdAt),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // Message bubble
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show sender name in group chats
                                  if (!isMe && widget.chat.chatType == 'group')
                                    Text(
                                      message.sender.username ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),

                                  // Message content
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),

                                  // Message time and status
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(message.createdAt),
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        SizedBox(width: 4),
                                        _buildMessageStatus(message.status),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    // TODO: Implement image picking
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(String status) {
    switch (status) {
      case 'sent':
        return Icon(Icons.done, size: 12, color: Colors.white);
      case 'delivered':
        return Icon(Icons.done_all, size: 12, color: Colors.white);
      case 'read':
        return Icon(Icons.done_all, size: 12, color: Colors.lightBlueAccent);
      default:
        return Icon(Icons.access_time, size: 12, color: Colors.white);
    }
  }
}

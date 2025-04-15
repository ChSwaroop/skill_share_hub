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
import 'package:skill_share_hub/colors.dart';

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

    // Fixed: Add a small delay before scrolling to ensure message is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
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
          : 'Last seen ${DateFormat('MMM d, HH:mm').format(otherUser.lastSeen!.add(Duration(hours: 5, minutes: 30)))}';
    } else {
      // For group chats, show number of members
      subtitle = '${widget.chat.participants.length} members';
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(
                widget.chat.getChatImage(authProvider.user!.id!),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.getChatName(userId!),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: ColorsUtil.textclr, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    // color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: ColorsUtil.primaryclr),
            onPressed: () => _callService.startAudioCall(
              context: context,
              participants: widget.chat.participants
                  .map((par) => par.id)
                  .whereType<String>()
                  .toList(),
              displayName: widget.chat.getChatName(userId!),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: ColorsUtil.primaryclr),
            onPressed: () => _callService.startVideoCall(
              context: context,
              participants: widget.chat.participants
                  .map((par) => par.id)
                  .whereType<String>()
                  .toList(),
              displayName: widget.chat.getChatName(userId!),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator for pagination
          if (_isLoading)
            LinearProgressIndicator(
              // backgroundColor: ColorsUtil.secondaryclr.withOpacity(0.3),
              color: ColorsUtil.primaryclr,
            ),

          // Messages list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                image: DecorationImage(
                  image: AssetImage("assets/images/chat_bg.png"),
                  // opacity: 0.7,
                  fit: BoxFit.cover,
                ),
              ),
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: ColorsUtil.secondaryclr,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color: ColorsUtil.secondarytxtclr,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              color: ColorsUtil.secondarytxtclr,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo is ScrollEndNotification &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          _scrollToBottom();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
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
                            final currDate = DateFormat('yyyy-MM-dd')
                                .format(message.createdAt);
                            showDate = prevDate != currDate;
                          }

                          // Check if this is a consecutive message from the same sender
                          bool showSender = true;
                          if (index > 0) {
                            final prevMessage = messages[index - 1];
                            if (prevMessage.sender.id == message.sender.id) {
                              // If previous message is from same sender and within 2 minutes
                              final timeDiff = message.createdAt
                                  .difference(prevMessage.createdAt);
                              if (timeDiff.inMinutes < 2) {
                                showSender = false;
                              }
                            }
                          }

                          return Column(
                            children: [
                              // Date header
                              if (showDate)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Chip(
                                    // backgroundColor: ColorsUtil.primaryclr,
                                    side: BorderSide.none,
                                    label: Text(
                                      // DateFormat('MMMM d, yyyy')
                                      //     .format(message.createdAt),
                                      DateFormat('MMMM d, yyyy').format(
                                          message.createdAt.add(
                                              Duration(hours: 5, minutes: 30))),
                                      style: TextStyle(
                                        color: ColorsUtil.primaryclr,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                  ),
                                ),

                              // Message bubble
                              Padding(
                                padding: EdgeInsets.only(
                                  top: showSender ? 12.0 : 4.0,
                                  bottom: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Avatar (only for received messages and when showing sender)
                                    if (!isMe && showSender)
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            ColorsUtil.secondaryclr,
                                        child: Text(
                                          (message.sender.username ?? "?")[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                    if (!isMe && !showSender)
                                      SizedBox(width: 32), // Space for avatar

                                    SizedBox(width: 8),

                                    // Message content
                                    Flexible(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 10.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? ColorsUtil.primaryclr
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 3,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Show sender name in group chats
                                            if (!isMe &&
                                                showSender &&
                                                widget.chat.chatType == 'group')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4.0),
                                                child: Text(
                                                  message.sender.username ?? "",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        ColorsUtil.secondaryclr,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),

                                            // Message content
                                            Text(
                                              message.content,
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : ColorsUtil.textclr,
                                                fontSize: 15,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            // Message time and status
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  DateFormat('HH:mm').format(
                                                      message.createdAt.add(
                                                          Duration(
                                                              hours: 5,
                                                              minutes: 30))),
                                                  style: TextStyle(
                                                    color: isMe
                                                        ? Colors.white70
                                                        : ColorsUtil
                                                            .secondarytxtclr,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                if (isMe) ...[
                                                  SizedBox(width: 4),
                                                  _buildMessageStatus(
                                                      message.status),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     color: ColorsUtil.secondaryclr.withOpacity(0.1),
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: Icon(Icons.image,
                //         color: ColorsUtil.primaryclr, size: 22),
                //     onPressed: () {
                //       // TODO: Implement image picking
                //     },
                //   ),
                // ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: ColorsUtil.textclr,
                      fontSize: 15,
                    ),
                    cursorColor: ColorsUtil.primaryclr,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      hintStyle: TextStyle(
                        color: ColorsUtil.secondarytxtclr,
                        fontSize: 15,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: ColorsUtil.primaryclr,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(String status) {
    Color iconColor = Colors.white70;

    switch (status) {
      case 'sent':
        return Icon(Icons.done, size: 12, color: iconColor);
      case 'delivered':
        return Icon(Icons.done_all, size: 12, color: iconColor);
      case 'read':
        return Icon(Icons.done_all, size: 12, color: Colors.white);
      default:
        return Icon(Icons.access_time, size: 12, color: iconColor);
    }
  }
}

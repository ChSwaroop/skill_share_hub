import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/providers/user_provider.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(id: "user", firstName: "Swaroop");
  ChatUser geminiUser = ChatUser(id: "model", firstName: "ChatBot");
  bool isThinking = false;

  // final String systemPrompt =
  //     "You are a helpful assistant specialized in education. Answer only questions related to education. If a question is outside the scope of education, respond with 'I can only answer questions related to education.'";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user!.username;
    currentUser.firstName = user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "Help Bot !",
          style: theme.textTheme.bodyMedium!.copyWith(
              color: const Color(0xFF1E1E1E), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashChat(
          inputOptions: InputOptions(
            alwaysShowSend: true,
            inputTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.black,
            ),
            inputDecoration: InputDecoration(
              labelStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              hintText: "Type something...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(360),
                borderSide: BorderSide(
                  color: ColorsUtil.primaryclr,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(360),
                borderSide: BorderSide(
                  color: ColorsUtil.primaryclr,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(360),
                borderSide: BorderSide(
                  color: ColorsUtil.primaryclr,
                ),
              ),
            ),
            cursorStyle: CursorStyle(
              color: ColorsUtil.primaryclr,
            ),
            sendOnEnter: true,
          ),
          typingUsers: (isThinking) ? [geminiUser] : [],
          messageListOptions: MessageListOptions(typingBuilder: (user) {
            return const Text("Thinking...");
          }),
          messageOptions: MessageOptions(
            currentUserContainerColor: ColorsUtil.primaryclr,
            currentUserTextColor: ColorsUtil.btntxtclr,
          ),
          currentUser: currentUser,
          onSend: onSend,
          messages: messages,
        ),
      ),
    );
  }

  void onSend(ChatMessage message) {
    debugPrint(message.text);
    messages = [message, ...messages];
    setState(() {
      isThinking = true;
    });

    List<Content> chatHistory = [
      // Content(parts: [Part.text(systemPrompt)], role: "model"),
      ...messages.reversed.map((message) {
        return Content(parts: [Part.text(message.text)], role: message.user.id);
      }).toList(),
    ];

    gemini.chat(chatHistory).then((value) {
      setState(() {
        messages = [
          ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: value!.output ?? ""),
          ...messages
        ];
        isThinking = false;
      });
    });
    setState(() {});
  }
}

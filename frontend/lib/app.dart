import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'package:skill_share_hub/providers/chat_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';
import 'package:skill_share_hub/theme.dart';
import 'package:skill_share_hub/views/home_views/home.dart';
import 'package:skill_share_hub/views/login_views/login.dart';
// import 'package:skill_share_hub/providers/theme_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AgoraRepo _agoraService;

  @override
  void initState() {
    super.initState();

    // Initialize Agora service with backend URL
    _agoraService = AgoraRepo(
      baseUrl: baseUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => ChatProvider())),
        ChangeNotifierProvider(create: ((context) => CallManagerProvider())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.user != null && userProvider.token != null) {
              // User is logged in, navigate to home screen
              return HomeScreen();
            } else {
              // User is not logged in, navigate to login screen
              return Login();
            }
          },
        ),
      ),
    );
  }
}

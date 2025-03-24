import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'package:skill_share_hub/providers/chat_provider.dart';
import 'package:skill_share_hub/providers/todo_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';
import 'package:skill_share_hub/repo/todorepo.dart';
import 'package:skill_share_hub/services/notification_services.dart';
import 'package:skill_share_hub/theme.dart';
import 'package:skill_share_hub/views/call_views/audio_call.dart';
import 'package:skill_share_hub/views/call_views/video_call.dart';
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final CallNotificationService _notificationService;
  late final AgoraRepo _agoraService;

  @override
  void initState() {
    super.initState();

    // Initialize Agora service with backend URL
    _agoraService = AgoraRepo(
      baseUrl: baseUrl,
    );

    // Access the UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Initialize notification service with UserProvider
    _notificationService = CallNotificationService(userProvider: userProvider);

    // Initialize notification service
    _initializeNotifications();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   // Access the UserProvider
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);

  //   // Initialize notification service with UserProvider
  //   _notificationService = CallNotificationService(userProvider: userProvider);
  //   _initializeNotifications();
  // }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize(
      onCallReceived: _handleIncomingCall,
    );
  }

  void _handleIncomingCall(
      String channelName, bool isVideo, String callerName) {
    // Navigate to appropriate call screen
    debugPrint("incoming callllll::::::::::::: " + channelName);
    _navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => CallManagerProvider(),
        child: isVideo
            ? VideoCallScreen(channelName: channelName)
            : AudioCallScreen(
                channelName: channelName,
                callerName: callerName,
              ),
      ),
    ));
    debugPrint("navigated to other page......");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => ChatProvider())),
        ChangeNotifierProvider(create: ((context) => CallManagerProvider())),
        ChangeNotifierProvider(
          create: (context) => TodoProvider(
            repository: TodoRepository(
              baseUrl: '$baseUrl/api',
              token: Provider.of<UserProvider>(context, listen: false)
                  .token!, // You should get this from secure storage
            ),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey, // Add this line
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

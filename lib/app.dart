import 'package:flutter/material.dart';
import 'package:skill_share_hub/theme.dart';
// import 'package:skill_share_hub/views/home_views/chat_bot.dart';
// import 'package:skill_share_hub/views/home_views/chat_menu.dart';
// import 'package:skill_share_hub/views/home_views/explore.dart';
// import 'package:skill_share_hub/views/home_views/home.dart';
// import 'package:skill_share_hub/views/home_views/profile.dart';
// import 'package:skill_share_hub/views/home_views/todo.dart';
import 'package:skill_share_hub/views/login_views/login.dart';
// import 'package:skill_share_hub/views/login_views/signup.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const Login(),
    );
  }
}
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gemini/flutter_gemini.dart";
import "package:provider/provider.dart";
import "package:skill_share_hub/app.dart";
import "package:skill_share_hub/providers/user_provider.dart";

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Gemini.init(apiKey: "AIzaSyBaddpZYCGYwy5vx3tBflUPAK5Vb8iZkcI");
  final userProvider = UserProvider();
  await userProvider.loadToken();
  await userProvider.loadUser();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => userProvider,
      child: MyApp(),
    ),
  );
}

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:skill_share_hub/app.dart";
import "package:skill_share_hub/providers/user_provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

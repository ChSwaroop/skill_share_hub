import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/views/login_views/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text("START", style: theme.textTheme.headlineLarge),
                    ],
                  ),
                  Text(
                    "UPGRADING",
                    style: theme.textTheme.headlineLarge!.copyWith(
                      color: ColorsUtil.primaryclr,
                      height: 0,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "YOUR ",
                        style: theme.textTheme.headlineLarge,
                      ),
                      Text(
                        "SKILLS",
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: ColorsUtil.primaryclr,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "TODAY !",
                    style: theme.textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            Spacer(),
            Text(
              "Login",
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: 31),
            TextFormField(
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: InputDecoration(
                label: Text("User name"),
              ),
            ),
            SizedBox(height: 18),
            TextFormField(
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: InputDecoration(
                label: Text("Password"),
              ),
            ),
            SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Do not have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUp()));
                  },
                  child: Text(
                    "SignUp",
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: ColorsUtil.primaryclr),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: theme.elevatedButtonTheme.style,
              onPressed: () {},
              child: Text(
                "Login",
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/views/blocked_users.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  color: ColorsUtil.btntxtclr,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      color: Colors.grey.shade300,
                    )
                  ]),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Theme",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: ColorsUtil.textclr,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30),
                    Row(
                      children: [
                        Icon(Icons.sunny),
                        SizedBox(width: 5),
                        Icon(Icons.nightlight_round_outlined),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  color: ColorsUtil.btntxtclr,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      color: Colors.grey.shade300,
                    )
                  ]),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Blocked Users",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: ColorsUtil.textclr,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlockedUsers(),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward_ios_rounded),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

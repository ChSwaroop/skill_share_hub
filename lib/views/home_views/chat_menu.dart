import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class ChatMenu extends StatefulWidget {
  const ChatMenu({super.key});

  @override
  State<ChatMenu> createState() => _ChatMenuState();
}

class _ChatMenuState extends State<ChatMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 31.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Image.asset("assets/images/icon.png"),
                Image.asset("assets/images/profile-pic1.png"),
              ],
            ),
            const SizedBox(height: 25),
            TextFormField(
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              decoration: const InputDecoration(hintText: "search for a person..."),
              cursorColor: ColorsUtil.primaryclr,
            ),
            // SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, ind) {
                  return Container(
                    height: 80,
                    width: width,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(horizontal: 5 , vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(1, 1),
                              spreadRadius: 3,
                              blurRadius: 5,
                              color: Colors.grey.shade300)
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/profile-pic1.png"),
                        Text(
                          "MongoDB",
                          style: theme.textTheme.titleMedium,
                        ),
                        Image.asset("assets/images/sync.png"),
                        Text(
                          "JavaScript",
                          style: theme.textTheme.titleMedium,
                        ),
                        Image.asset("assets/images/profile-pic2.png"),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Create Group",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

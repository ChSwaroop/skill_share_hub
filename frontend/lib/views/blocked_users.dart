import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({super.key});

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Blocked Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: Column(
          children: [
            blocked(theme, "Swaroop", "assets/images/profile-pic1.png"),
            SizedBox(height: 20),
            blocked(theme, "Swaroop", "assets/images/profile-pic1.png"),
            SizedBox(height: 20),
            blocked(theme, "Swaroop", "assets/images/profile-pic1.png"),
          ],
        ),
      ),
    );
  }

  Container blocked(ThemeData theme, String userName, String imgUrl) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: ColorsUtil.btntxtclr,
        border: Border.all(
          color: ColorsUtil.shadowClr,
          width: 2,
        ),
        // color: ColorsUtil.primaryclr,
        boxShadow: [
          BoxShadow(
            offset: Offset(2, 2),
            color: Colors.grey.shade300,
            blurRadius: 7,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(360),
                  child: Image.asset(
                    imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 30),
              Text(userName, style: theme.textTheme.titleMedium),
            ],
          ),
          OutlinedButton(
            style: theme.outlinedButtonTheme.style!.copyWith(
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
              ),
            ),
            onPressed: () {},
            child: Text(
              "Unblock",
              style: theme.textTheme.labelSmall,
            ),
          )
        ],
      ),
    );
  }
}

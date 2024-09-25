import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class card_custom extends StatelessWidget {
  const card_custom({
    super.key,
    required this.theme,
    required this.heading,
    required this.txt,
  });

  final ThemeData theme;
  final String heading;
  final String txt;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFFFE1E4),
        boxShadow: [
          BoxShadow(
            offset: Offset(1, 1),
            spreadRadius: 1,
            blurRadius: 10,
            color: Colors.grey.shade200
          )
        ]
        // color: ColorsUtil.primaryclr
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            heading,
            style: theme.textTheme.bodySmall!.copyWith(
              color: ColorsUtil.primaryclr,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            txt,
            style: theme.textTheme.headlineMedium!
                .copyWith(color: ColorsUtil.primaryclr),
          ),
        ],
      ),
    );
  }
}

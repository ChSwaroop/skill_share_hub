import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

ThemeData theme = ThemeData(
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 53,
      color: ColorsUtil.secondaryclr,
    ),
    headlineMedium: TextStyle(
      fontSize: 32,
      color: ColorsUtil.primaryclr,
    ),
    headlineSmall: TextStyle(
      color: Colors.black,
      fontSize: 20,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      color: ColorsUtil.secondarytxtclr,
      // height: 20,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 15
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      color: ColorsUtil.secondarytxtclr
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      color: Colors.white
    ),
    titleMedium: TextStyle(
      fontSize: 11,
      color: ColorsUtil.thirdtxtclr,
    ),
    titleSmall: TextStyle(
      fontSize: 8,
      color: Color(0xFFBABABA),
    )
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: ColorsUtil.secondarytxtclr,
      fontSize: 13,
    ),
    contentPadding: const EdgeInsets.only(left: 25 , top: 17 , bottom: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(color: ColorsUtil.borderclr),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(color: ColorsUtil.borderclr),
    ),
    hintStyle: const TextStyle(
      fontSize: 13,
      color: ColorsUtil.secondarytxtclr,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(160, 50),
      backgroundColor: ColorsUtil.primaryclr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      )
    )
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(
        color: ColorsUtil.primaryclr,
      ),
      padding: const EdgeInsets.all(0)
    ),
  
  ),
);

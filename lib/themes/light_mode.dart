import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.grey.shade100,
    inversePrimary: Colors.grey.shade800,
  ),
  scaffoldBackgroundColor: Colors.grey.shade300,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade200, // 🔹 Blue 600
    foregroundColor: Colors.white, // 🔸 Title and icons color
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(
      color: Colors.black, // ← Icon color
    ),
  ),
);

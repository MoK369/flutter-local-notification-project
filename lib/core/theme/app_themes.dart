import 'package:flutter/material.dart';

abstract class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      ),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.teal,
      onPrimary: Colors.white,
      secondary: Colors.tealAccent,
      onSecondary: Colors.black,
      error: Colors.white,
      onError: Colors.red,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );
}

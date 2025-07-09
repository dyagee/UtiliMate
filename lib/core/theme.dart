import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  scaffoldBackgroundColor: Colors.grey[100],
  textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
);

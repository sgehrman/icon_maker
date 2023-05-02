import 'package:flutter/material.dart';

class ThemePrefs {
  factory ThemePrefs() {
    return _instance ??= ThemePrefs._();
  }

  ThemePrefs._();

  static ThemePrefs? _instance;

  ValueNotifier<String> font = ValueNotifier<String>('Roboto');
}

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class ToggleTheme {
  Future<bool> call() async {
    final box = await Hive.openBox(AppConstants.themeBoxName);
    final currentTheme = box.get(AppConstants.isDarkModeKey, defaultValue: false);
    final newTheme = !currentTheme;
    await box.put(AppConstants.isDarkModeKey, newTheme);
    return newTheme;
  }

  Future<bool> getCurrentTheme() async {
    final box = await Hive.openBox(AppConstants.themeBoxName);
    return box.get(AppConstants.isDarkModeKey, defaultValue: false);
  }
}
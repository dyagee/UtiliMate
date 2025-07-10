// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define custom color schemes
class AppThemes {
  static final Map<String, Color> _seedColors = {
    'Default Blue': Colors.blue,
    'Green Eco': Colors.green,
    'Purple Haze': Colors.purple,
    // Add more seed colors here if desired
  };

  static ColorScheme getScheme(String name, Brightness brightness) {
    final Color seedColor = _seedColors[name] ?? Colors.blue;
    return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  }

  static List<String> getThemeNames() {
    return _seedColors.keys.toList();
  }
}

class ThemeService with ChangeNotifier {
  static const String _themeKey = 'selectedTheme';
  static const String _fontSizeKey = 'fontSizeFactor';
  static const String _brightnessKey = 'appBrightness';

  String _selectedThemeName = 'Default Blue';
  double _fontSizeFactor = 1.0;
  Brightness? _appBrightness;

  ThemeService() {
    _loadSettings();
  }

  String get selectedThemeName => _selectedThemeName;
  double get fontSizeFactor => _fontSizeFactor;
  Brightness? get appBrightness => _appBrightness;

  ThemeData getThemeData(BuildContext context) {
    Brightness effectiveBrightness;
    if (_appBrightness == null) {
      effectiveBrightness = MediaQuery.of(context).platformBrightness;
    } else {
      effectiveBrightness = _appBrightness!;
    }

    final ColorScheme colorScheme = AppThemes.getScheme(
      _selectedThemeName,
      effectiveBrightness,
    );

    // Get a base TextTheme from a standard light/dark theme.
    // This ensures all TextStyles have concrete (non-null) fontSizes.
    final TextTheme baseTextTheme =
        (effectiveBrightness == Brightness.light
                ? ThemeData.light()
                : ThemeData.dark())
            .textTheme;

    // Manually create a new TextTheme by copying and scaling each TextStyle,
    // ensuring fontSize is always non-null.
    final TextTheme scaledTextTheme = TextTheme(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize:
            (baseTextTheme.displayLarge?.fontSize ?? 57) * _fontSizeFactor,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize:
            (baseTextTheme.displayMedium?.fontSize ?? 45) * _fontSizeFactor,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize:
            (baseTextTheme.displaySmall?.fontSize ?? 36) * _fontSizeFactor,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize:
            (baseTextTheme.headlineLarge?.fontSize ?? 32) * _fontSizeFactor,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize:
            (baseTextTheme.headlineMedium?.fontSize ?? 28) * _fontSizeFactor,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize:
            (baseTextTheme.headlineSmall?.fontSize ?? 24) * _fontSizeFactor,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * _fontSizeFactor,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * _fontSizeFactor,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * _fontSizeFactor,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * _fontSizeFactor,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * _fontSizeFactor,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * _fontSizeFactor,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * _fontSizeFactor,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * _fontSizeFactor,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * _fontSizeFactor,
      ),
    ).apply(
      // Ensure text colors adapt to the new color scheme and brightness
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    // Create the final ThemeData
    final finalTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: effectiveBrightness,
      textTheme: scaledTextTheme, // Use the manually scaled TextTheme
    );

    // Apply other component themes
    return finalTheme.copyWith(
      appBarTheme: finalTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        titleTextStyle: finalTheme.appBarTheme.titleTextStyle?.copyWith(
          color: colorScheme.onPrimary,
        ),
        iconTheme: finalTheme.appBarTheme.iconTheme?.copyWith(
          color: colorScheme.onPrimary,
        ),
        actionsIconTheme: finalTheme.appBarTheme.actionsIconTheme?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      cardTheme: finalTheme.cardTheme.copyWith(
        color: colorScheme.surfaceContainerHighest,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeName = prefs.getString(_themeKey) ?? 'Default Blue';
    _fontSizeFactor = prefs.getDouble(_fontSizeKey) ?? 1.0;
    final String? brightnessString = prefs.getString(_brightnessKey);
    if (brightnessString == 'light') {
      _appBrightness = Brightness.light;
    } else if (brightnessString == 'dark') {
      _appBrightness = Brightness.dark;
    } else {
      _appBrightness = null;
    }
    notifyListeners();
  }

  Future<void> setSelectedThemeName(String themeName) async {
    if (_selectedThemeName != themeName) {
      _selectedThemeName = themeName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeName);
      notifyListeners();
    }
  }

  Future<void> setFontSizeFactor(double factor) async {
    if (_fontSizeFactor != factor) {
      _fontSizeFactor = factor;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, factor);
      notifyListeners();
    }
  }

  Future<void> setAppBrightness(Brightness? brightness) async {
    if (_appBrightness != brightness) {
      _appBrightness = brightness;
      final prefs = await SharedPreferences.getInstance();
      if (brightness == Brightness.light) {
        await prefs.setString(_brightnessKey, 'light');
      } else if (brightness == Brightness.dark) {
        await prefs.setString(_brightnessKey, 'dark');
      } else {
        await prefs.remove(_brightnessKey);
      }
      notifyListeners();
    }
  }
}

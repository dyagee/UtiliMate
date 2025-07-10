import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilimate/services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Selection Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.palette,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'App Theme',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: themeService.selectedThemeName,
                      decoration: const InputDecoration(
                        labelText: 'Select Color Theme',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          AppThemes.getThemeNames().map((String themeName) {
                            return DropdownMenuItem<String>(
                              value: themeName,
                              child: Text(themeName),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          themeService.setSelectedThemeName(newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Brightness?>(
                      value: themeService.appBrightness,
                      decoration: const InputDecoration(
                        labelText: 'App Brightness',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('System Default'),
                        ),
                        DropdownMenuItem(
                          value: Brightness.light,
                          child: Text('Light Mode'),
                        ),
                        DropdownMenuItem(
                          value: Brightness.dark,
                          child: Text('Dark Mode'),
                        ),
                      ],
                      onChanged: (Brightness? newValue) {
                        themeService.setAppBrightness(newValue);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Font Size Adjustment Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.text_format,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Font Size',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: themeService.fontSizeFactor,
                      min: 0.8, // Smallest font size
                      max: 1.2, // Largest font size
                      divisions: 4, // 0.8, 0.9, 1.0, 1.1, 1.2
                      label: themeService.fontSizeFactor.toStringAsFixed(1),
                      onChanged: (double newValue) {
                        themeService.setFontSizeFactor(newValue);
                      },
                    ),
                    Center(
                      child: Text(
                        'Adjust text size',
                        style: TextStyle(
                          fontSize: 16 * themeService.fontSizeFactor,
                        ), // Preview text
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

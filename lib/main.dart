import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilimate/screens/home_screen.dart';
import 'package:utilimate/services/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'UtiliMate',
          debugShowCheckedModeBanner: false,
          theme: themeService.getThemeData(context), // Apply the dynamic theme
          home: const HomeScreen(),
        );
      },
    );
  }
}

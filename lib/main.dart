// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilimate/services/theme_service.dart';
import 'package:utilimate/screens/home_screen.dart';
import 'package:utilimate/screens/file_browser_screen.dart';
import 'package:utilimate/screens/settings_screen.dart';
import 'package:utilimate/widgets/categories_modal_sheet.dart';

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
          theme: themeService.getThemeData(context),
          home: const MainAppScaffold(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Main scaffold for the app, managing bottom navigation and page views.
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Define the list of main screens for the PageView
  // Note: Category screens are NOT directly in PageView anymore,
  // they are navigated to from the modal sheet.
  final List<Widget> _screens = const [
    HomeScreen(), // All Tools
    // Placeholder for Categories tab - it will trigger a modal, not a page view
    SizedBox(), // This index will be used for the modal sheet
    FileBrowserScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Index 1 is "Categories"
      _showCategoriesModal();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  void _showCategoriesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return const CategoriesModalSheet(); // Our new modal sheet widget
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens, // Use the defined list of screens
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Changed to home icon for 'All Tools'
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category), // Icon for Categories
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Fixed type, no scrolling
        showUnselectedLabels: true, // Show all labels
      ),
    );
  }
}

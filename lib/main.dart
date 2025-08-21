// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilimate/screens/home_screen.dart';
import 'package:utilimate/services/theme_service.dart';
import 'package:utilimate/screens/file_browser_screen.dart';
import 'package:utilimate/screens/settings_screen.dart';
import 'package:utilimate/widgets/categories_modal_sheet.dart';
import 'package:utilimate/services/connectivity_service.dart'; // Import the new service
import 'dart:developer' as developer; // For logging

// Define a global key for the navigator state
// This is crucial for showing SnackBars from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the ConnectivityService right at the start of the app.
  // This will begin listening for connectivity changes immediately.
  ConnectivityService();
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
          // Provide the navigatorKey to MaterialApp. This allows global access
          // to the NavigatorState and ScaffoldMessenger for showing SnackBars.
          navigatorKey: navigatorKey,
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
  late final ConnectivityService _connectivityService; // Declare the service

  // Define the list of main screens for the PageView
  final List<Widget> _screens = const [
    HomeScreen(), // All Tools
    SizedBox(), // This index will be used for the modal sheet (Categories)
    FileBrowserScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _connectivityService = ConnectivityService(); // Get the singleton instance

    // You can optionally listen for connectivity changes here if you want
    // to update UI elements within MainAppScaffold based on connectivity.
    // However, the SnackBar alerts are handled internally by ConnectivityService.
    _connectivityService.onConnectivityChange.listen((isConnected) {
      developer.log('MainAppScaffold: Connectivity changed to $isConnected');
      // No setState here, as SnackBar is handled globally by the service.
      // Add any scaffold-level UI changes here if necessary.
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // No need to dispose _connectivityService here, as it's a global singleton
    // managed at the application level. Its dispose method is called only when
    // the entire application is shutting down, which is not managed by a Widget's dispose.
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

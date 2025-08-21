// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:utilimate/main.dart'; // Import main.dart to access navigatorKey
import 'dart:developer' as developer;

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    _initConnectivityStream();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isConnected = true; // Assume connected initially

  // Public getter for current connectivity status
  bool get isConnected => _isConnected;

  // Stream to notify listeners about connectivity changes
  final StreamController<bool> _connectivityChangeController =
      StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChange => _connectivityChangeController.stream;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _currentSnackBar;

  // Initialize the connectivity stream listener
  void _initConnectivityStream() {
    // FIX: Updated to handle List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    // Also check initial status
    _checkInitialConnectivity();
  }

  // Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    // FIX: Updated to handle List<ConnectivityResult> returned by checkConnectivity()
    final List<ConnectivityResult> connectivityResult =
        await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  // Update connection status and notify listeners
  // FIX: Parameter type changed to List<ConnectivityResult>
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    bool previousStatus = _isConnected;
    // Determine connection status based on the list
    _isConnected =
        result.isNotEmpty && !result.contains(ConnectivityResult.none);
    developer.log(
      'ConnectivityService: Connection status changed to: $_isConnected',
    );

    if (previousStatus != _isConnected) {
      _connectivityChangeController.add(_isConnected);
      _showConnectivitySnackBar(_isConnected);
    }
  }

  // Show a SnackBar to alert the user about connectivity changes
  void _showConnectivitySnackBar(bool connected) {
    if (navigatorKey.currentContext == null) {
      developer.log(
        'ConnectivityService: No current context to show SnackBar.',
      );
      return;
    }

    // Dismiss any existing SnackBar first
    _currentSnackBar?.close();

    final message =
        connected
            ? 'Internet connection restored! You are online. 🌐'
            : 'No internet connection. Some tools may not work. 🔌';
    final color = connected ? Colors.green : Colors.red;

    _currentSnackBar = ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration:
            connected
                ? const Duration(seconds: 3)
                : const Duration(days: 1), // Persistent for offline
        action:
            connected
                ? null
                : SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    _currentSnackBar?.close();
                  },
                ),
      ),
    );
  }

  // Dispose of the stream subscription
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityChangeController.close();
  }
}

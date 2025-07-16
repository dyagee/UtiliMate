// lib/models/tool_item.dart
import 'package:flutter/material.dart';

// Enum to distinguish between offline and web-based tools
enum ToolType {
  offline, // Native, works without internet (mostly)
  web, // Requires internet, loads in WebView
}

/// A data model for representing a single tool in the app.
class ToolItem {
  final String name; // Display name of the tool
  final IconData icon; // Material icon for the tool
  final Widget screen; // The Flutter screen widget associated with this tool
  final ToolType type; // Whether it's an offline (native) or web tool
  final String helpContentKey; // Key to retrieve help content from AppConstants

  const ToolItem({
    required this.name,
    required this.icon,
    required this.screen,
    required this.type,
    required this.helpContentKey,
  });
}

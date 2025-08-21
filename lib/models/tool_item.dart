// lib/models/tool_item.dart
import 'package:flutter/material.dart';

enum ToolType { offline, online }

class ToolItem {
  final String name;
  final IconData icon;
  final Widget Function(BuildContext) screenBuilder;
  // FIX: Added screenType property to store the Type of the screen
  final Type screenType;
  final ToolType type;
  final String helpContentKey;

  const ToolItem({
    required this.name,
    required this.icon,
    required this.screenBuilder,
    required this.screenType, // FIX: Updated constructor parameter
    required this.type,
    required this.helpContentKey,
  });
}

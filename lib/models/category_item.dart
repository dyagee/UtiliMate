import 'package:flutter/material.dart';

/// A data model for representing a tool category in the app.
class CategoryItem {
  final String name; // Display name of the category
  final IconData icon; // Material icon for the category
  final Widget
  screen; // The Flutter screen widget associated with this category

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.screen,
  });
}

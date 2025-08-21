// lib/models/category_item.dart
import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  // This will be a builder for the category screen itself
  final Widget Function(BuildContext) screenBuilder;
  final String helpContentKey;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.screenBuilder,
    required this.helpContentKey,
  });
}

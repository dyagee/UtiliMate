// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/help_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String helpContentKey;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.helpContentKey,
    this.showBackButton = true,
    this.bottom,
    this.actions,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
      // Merge provided actions with the default help button
      actions: [
        ...?actions, // NEW: Spread the provided actions first
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return HelpDialog(
                  title: '$title Help',
                  markdownContent:
                      AppConstants.helpContent[helpContentKey] ??
                      'No help content available.',
                );
              },
            );
          },
        ),
      ],
      bottom: bottom,
    );
  }
}

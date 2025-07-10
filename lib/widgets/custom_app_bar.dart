// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:utilimate/widgets/help_dialog.dart';
import 'package:utilimate/utils/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String helpContentKey; // Key to fetch help content from AppConstants

  const CustomAppBar({
    super.key,
    required this.title,
    required this.helpContentKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Help',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => HelpDialog(
                    title: '$title Help',
                    markdownContent: AppConstants.helpContent[helpContentKey]!,
                  ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

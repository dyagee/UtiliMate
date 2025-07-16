// lib/screens/video_downloaders_category_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/widgets/custom_app_bar.dart'; // For the AppBar

class VideoDownloadersCategoryScreen extends StatelessWidget {
  const VideoDownloadersCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter AppConstants.allTools to get only Video Downloaders
    final videoDownloaders = AppConstants.getVideoDownloaders();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Video Downloaders',
        helpContentKey:
            'VIDEO_DOWNLOADERS_CATEGORY', // Key for Video Downloaders category help
      ),
      body: ToolGrid(
        tools: videoDownloaders,
        title:
            'Online Video Downloaders', // Title specifically for this category screen
      ),
    );
  }
}

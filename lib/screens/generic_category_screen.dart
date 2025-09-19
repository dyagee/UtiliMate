import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';
import 'package:utilimate/services/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GenericCategoryScreen extends StatefulWidget {
  final String title;
  final List<ToolItem> tools;
  final String categoryHelpContentKey;

  const GenericCategoryScreen({
    super.key,
    required this.title,
    required this.tools,
    required this.categoryHelpContentKey,
  });

  @override
  State<GenericCategoryScreen> createState() => _GenericCategoryScreenState();
}

class _GenericCategoryScreenState extends State<GenericCategoryScreen> {
  // Holds the AdWidget for the banner ad
  AdWidget? _bannerAdWidget;

  @override
  void initState() {
    super.initState();

    // Get the banner ad widget using the singleton's method.
    _bannerAdWidget = AdManager().getBannerAdWidget();

    // Use a delayed future to force a rebuild after the ad has loaded.
    // This ensures the ad is displayed correctly even if it loads
    // after the initial widget build.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _bannerAdWidget = AdManager().getBannerAdWidget();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the banner ad is ready to be displayed
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        helpContentKey: widget.categoryHelpContentKey,
      ),
      body: ToolGrid(tools: widget.tools, title: widget.title),
      bottomNavigationBar:
          isBannerAdReady
              ? SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: _bannerAdWidget!,
              )
              : null,
    );
  }
}

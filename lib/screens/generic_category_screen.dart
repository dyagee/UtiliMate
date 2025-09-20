import 'package:flutter/material.dart';
import 'package:utilimate/models/tool_item.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/tool_grid.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        helpContentKey: widget.categoryHelpContentKey,
      ),
      body: ToolGrid(tools: widget.tools, title: widget.title),
    );
  }
}

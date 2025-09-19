import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/services/ad_manager.dart'; // Import AdManager
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads

class RandomTextGeneratorScreen extends StatefulWidget {
  const RandomTextGeneratorScreen({super.key});

  @override
  State<RandomTextGeneratorScreen> createState() =>
      _RandomTextGeneratorScreenState();
}

class _RandomTextGeneratorScreenState extends State<RandomTextGeneratorScreen> {
  final TextEditingController _paragraphCountController = TextEditingController(
    text: '3',
  );
  String _generatedText = 'Tap "Generate Text" to get random paragraphs.';
  String? _errorMessage;
  AdWidget? _bannerAdWidget;

  // A long string of Lorem Ipsum text to generate paragraphs from
  static const String _loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      "Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida. Duis ac tellus et risus adipiscing euismod. Nam dictum proin a neque. In eget metus id velit ornare aliquam. Praesent egestas leo in ante. Proin neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare bibendum. In hac habitasse platea dictumst."
      "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean lacinia bibendum nulla sed consectetur. Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus."
      "Maecenas sed diam eget risus varius blandit sit amet non magna. Etiam porta sem malesuada magna mollis euismod. Cras mattis consectetur purus sit amet fermentum. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam quis risus eget urna mollis ornare vel eu leo."
      "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean lacinia bibendum nulla sed consectetur."
      "Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Donec ullamcorper nulla non metus auctor fringilla. Nulla vitae elit libero, a pharetra augue. Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      "Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Nullam quis risus eget urna mollis ornare vel eu leo."
      "Sed posuere consectetur est at lobortis. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Donec ullamcorper nulla non metus auctor fringilla. Cras mattis consectetur purus sit amet fermentum. Donec id elit non mi porta gravida at eget metus. Nullam id dolor id nibh ultricies vehicula ut id elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      "Vestibulum id ligula porta felis euismod semper. Nullam id dolor id nibh ultricies vehicula ut id elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Nullam quis risus eget urna mollis ornare vel eu leo."
      "Aenean lacinia bibendum nulla sed consectetur. Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit.";

  @override
  void initState() {
    super.initState();
    // Initialize the banner ad widget
    _bannerAdWidget = AdManager().getBannerAdWidget();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _bannerAdWidget = AdManager().getBannerAdWidget();
        });
      }
    });
  }

  void _generateText() {
    setState(() {
      _errorMessage = null;
    });

    final int? paragraphCount = int.tryParse(_paragraphCountController.text);

    if (paragraphCount == null || paragraphCount <= 0) {
      setState(() {
        _errorMessage =
            'Please enter a valid number of paragraphs (e.g., 1-10).';
        _generatedText = '';
      });
      return;
    }

    final List<String> paragraphs = _loremIpsum.split(
      '. ',
    ); // Split into sentences/phrases
    final StringBuffer generatedBuffer = StringBuffer();
    final Random random = Random();

    for (int i = 0; i < paragraphCount; i++) {
      int sentenceCount = random.nextInt(5) + 3; // 3-7 sentences per paragraph
      for (int j = 0; j < sentenceCount; j++) {
        generatedBuffer.write(paragraphs[random.nextInt(paragraphs.length)]);
        if (j < sentenceCount - 1) {
          generatedBuffer.write('. '); // Re-add period and space
        }
      }
      generatedBuffer.write(
        '.\n\n',
      ); // End paragraph with period and two newlines
    }

    setState(() {
      _generatedText =
          generatedBuffer.toString().trim(); // Remove trailing newlines
    });
  }

  void _copyToClipboard() {
    if (_generatedText.isNotEmpty &&
        _generatedText != 'Tap "Generate Text" to get random paragraphs.') {
      Clipboard.setData(ClipboardData(text: _generatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No text to copy.')));
    }
  }

  @override
  void dispose() {
    _paragraphCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Random Text Generator',
        helpContentKey: 'RANDOM_TEXT_GENERATOR_TOOL',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.text_format,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Number of Paragraphs',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _paragraphCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter number of paragraphs (e.g., 1-10)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Generate Text',
                      onPressed: () => _generateText(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        _generatedText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Copy to Clipboard',
                      onPressed: () => _copyToClipboard(),
                      icon: Icons.copy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

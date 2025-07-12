import 'package:flutter/material.dart';
import 'package:utilimate/screens/web_view_screen.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class WebToolsScreen extends StatelessWidget {
  const WebToolsScreen({super.key});

  // Helper method to build tool cards for web views
  Widget _buildWebToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String url,
    required String helpKey,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => WebViewScreen(
                    title: title,
                    url: url,
                    helpContentKey: helpKey,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: CustomButton(
                  text: 'Open Web Tool',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WebViewScreen(
                              title: title,
                              url: url,
                              helpContentKey: helpKey,
                            ),
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build a category header
  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Web Tools',
        helpContentKey: 'WEB_TOOLS',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Disclaimer at the top
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Disclaimer:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These tools are provided via external websites. UtiliMate is not responsible for their content, advertisements, or how they handle your data/files. File downloads may occur outside the app\'s direct control.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Document Conversion Tools
            _buildCategoryHeader(context, 'Document Conversions'),
            _buildWebToolCard(
              context,
              icon: Icons.description,
              title: 'Word to PDF Converter',
              description:
                  'Convert Word documents (.docx) to PDF format online.',
              url: 'https://smallseotools.com/word-to-pdf/',
              helpKey: 'WEB_WORD_TO_PDF',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.text_snippet,
              title: 'PDF to Word Converter',
              description:
                  'Convert PDF documents to editable Word (.docx) format online.',
              url: 'https://smallseotools.com/pdf-to-word/',
              helpKey: 'WEB_PDF_TO_WORD',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.slideshow,
              title: 'PowerPoint to PDF Converter',
              description:
                  'Convert PowerPoint presentations (.pptx) to PDF format online.',
              url: 'https://smallseotools.com/powerpoint-to-pdf/',
              helpKey: 'WEB_PPT_TO_PDF',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.table_chart,
              title: 'Excel to PDF Converter',
              description:
                  'Convert Excel spreadsheets (.xlsx) to PDF format online.',
              url: 'https://smallseotools.com/excel-to-pdf/',
              helpKey: 'WEB_EXCEL_TO_PDF',
            ),

            // Image Tools
            _buildCategoryHeader(context, 'Image Tools'),
            _buildWebToolCard(
              context,
              icon: Icons.crop,
              title: 'Crop Image',
              description: 'Crop images online to your desired dimensions.',
              url: 'https://smallseotools.com/crop-image/',
              helpKey: 'WEB_CROP_IMAGE',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.photo_size_select_small,
              title: 'Image Compressor',
              description: 'Compress image files to reduce their size online.',
              url: 'https://smallseotools.com/image-compressor/',
              helpKey: 'WEB_IMAGE_COMPRESSOR',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.image,
              title: 'Online Photo Editor',
              description:
                  'Perform basic photo editing tasks directly in your browser.',
              url: 'https://smallseotools.com/image-editor/',
              helpKey: 'WEB_PHOTO_EDITOR',
            ),

            // Website Tools
            _buildCategoryHeader(context, 'Website Tools'),
            _buildWebToolCard(
              context,
              icon: Icons.screenshot,
              title: 'Website Screenshot Generator',
              description: 'Generate a screenshot of any website online.',
              url: 'https://smallseotools.com/website-screenshot-generator/',
              helpKey: 'WEB_WEBSITE_SCREENSHOT',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.star,
              title: 'Favicon Generator',
              description: 'Create a favicon for your website from an image.',
              url: 'https://smallseotools.com/favicon-generator/',
              helpKey: 'WEB_FAVICON_GENERATOR',
            ),

            // Video Downloaders
            _buildCategoryHeader(context, 'Video Downloaders'),
            _buildWebToolCard(
              context,
              icon: Icons.download,
              title: 'Any Video Downloader',
              description: 'Download videos from various online platforms.',
              url: 'https://smallseotools.com/online-video-downloader/',
              helpKey: 'WEB_ANY_VIDEO_DOWNLOADER',
            ),
            _buildWebToolCard(
              context,
              icon:
                  Icons
                      .facebook, // Using generic icons as specific ones aren't in Material Icons
              title: 'Facebook Video Downloader',
              description: 'Download videos from Facebook.',
              url: 'https://smallseotools.com/facebook-video-downloader/',
              helpKey: 'WEB_FACEBOOK_VIDEO_DOWNLOADER',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.search, // Placeholder icon
              title: 'Twitter Video Downloader',
              description: 'Download videos from Twitter.',
              url: 'https://smallseotools.com/twitter-video-downloader/',
              helpKey: 'WEB_TWITTER_VIDEO_DOWNLOADER',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.camera_alt, // Placeholder icon
              title: 'Instagram Video Downloader',
              description: 'Download videos from Instagram.',
              url: 'https://smallseotools.com/instagram-video-downloader/',
              helpKey: 'WEB_INSTAGRAM_VIDEO_DOWNLOADER',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.push_pin, // Placeholder icon
              title: 'Pinterest Video Downloader',
              description: 'Download videos from Pinterest.',
              url: 'https://smallseotools.com/pinterest-video-downloader/',
              helpKey: 'WEB_PINTEREST_VIDEO_DOWNLOADER',
            ),
            _buildWebToolCard(
              context,
              icon: Icons.music_note, // Placeholder icon
              title: 'TikTok Video Downloader',
              description: 'Download videos from TikTok.',
              url: 'https://smallseotools.com/tiktok-video-downloader/',
              helpKey: 'WEB_TIKTOK_VIDEO_DOWNLOADER',
            ),

            // SEO Tools
            _buildCategoryHeader(context, 'SEO Tools'),
            _buildWebToolCard(
              context,
              icon: Icons.lightbulb,
              title: 'Keyword Suggestion Tool',
              description: 'Get keyword ideas for your content or website.',
              url: 'https://smallseotools.com/keyword-suggestion-tool/',
              helpKey: 'WEB_KEYWORD_SUGGESTION',
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/screens/pdf_tools_screen.dart';
import 'package:utilimate/screens/text_tools_screen.dart';
import 'package:utilimate/screens/image_tools_screen.dart';
import 'package:utilimate/screens/unit_converter_screen.dart';
import 'package:utilimate/screens/file_browser_screen.dart';
import 'package:utilimate/screens/settings_screen.dart';
// Removed: import 'package:utilimate/screens/video_tools_screen.dart';
import 'package:utilimate/screens/qr_barcode_tools_screen.dart';
import 'package:utilimate/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UtiliMate')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PDF Tools Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'PDF Tools',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Go to PDF Tools',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PdfToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Text Tools Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Text Tools',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Go to Text Tools',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TextToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Image Tools Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Image Tools',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Go to Image Tools',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ImageToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Unit Converter Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unit Converter',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Go to Unit Converter',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const UnitConverterScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // File Management Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'File Management',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Browse Files',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FileBrowserScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Removed Video Tools Card
                // Card(
                //   margin: const EdgeInsets.only(bottom: 24),
                //   child: Padding(
                //     padding: const EdgeInsets.all(20.0),
                //     child: Column(
                //       children: [
                //         Icon(Icons.video_collection, size: 60, color: Theme.of(context).colorScheme.primary),
                //         const SizedBox(height: 16),
                //         Text(
                //           'Video Tools',
                //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                //         ),
                //         const SizedBox(height: 16),
                //         CustomButton(
                //           text: 'Go to Video Tools',
                //           onPressed: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(builder: (context) => const VideoToolsScreen()),
                //             );
                //           },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // QR & Barcode Tools Card
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'QR & Barcode Tools',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Go to QR Tools',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const QrBarcodeToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Adjust Settings',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

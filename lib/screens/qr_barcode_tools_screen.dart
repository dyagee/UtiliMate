import 'package:flutter/material.dart';
import 'package:utilimate/screens/qr_generator_screen.dart';
import 'package:utilimate/screens/qr_scanner_screen.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class QrBarcodeToolsScreen extends StatelessWidget {
  const QrBarcodeToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'QR & Barcode Tools',
        helpContentKey: 'QR_BARCODE_TOOLS', // Define this key in AppConstants
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Generator Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrGeneratorScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Generate QR Code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create QR codes from text, URLs, and more.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButton(
                          text: 'Generate',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrGeneratorScreen(),
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
            ),
            // QR & Barcode Scanner Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Scan QR & Barcode',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan QR codes and various barcode types using your camera.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButton(
                          text: 'Scan',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrScannerScreen(),
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
            ),
          ],
        ),
      ),
    );
  }
}

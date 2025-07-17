// lib/screens/generators/random_number_generator_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For random number generation
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class RandomNumberGeneratorScreen extends StatefulWidget {
  const RandomNumberGeneratorScreen({super.key});

  @override
  State<RandomNumberGeneratorScreen> createState() =>
      _RandomNumberGeneratorScreenState();
}

class _RandomNumberGeneratorScreenState
    extends State<RandomNumberGeneratorScreen> {
  final TextEditingController _lengthController = TextEditingController(
    text: '10',
  ); // Default length 10
  String _generatedNumber = 'Tap "Generate Number" to get a random number.';
  String? _errorMessage;
  final Random _random = Random();

  void _generateNumber() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    final int? length = int.tryParse(_lengthController.text);

    if (length == null || length <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid positive length for the digits.';
        _generatedNumber = '';
      });
      return;
    }
    if (length > 100) {
      // Prevent excessively long numbers for performance/display
      setState(() {
        _errorMessage = 'Length cannot exceed 100 digits.';
        _generatedNumber = '';
      });
      return;
    }

    // Generate a random number string of the specified length
    // Ensure the first digit is not zero for a true 'length'
    String number = '';
    if (length > 0) {
      number += (_random.nextInt(9) + 1).toString(); // First digit 1-9
      for (int i = 1; i < length; i++) {
        number += _random.nextInt(10).toString(); // Remaining digits 0-9
      }
    }

    setState(() {
      _generatedNumber = number;
    });
  }

  void _copyToClipboard() {
    if (_generatedNumber.isNotEmpty &&
        _generatedNumber != 'Tap "Generate Number" to get a random number.') {
      Clipboard.setData(ClipboardData(text: _generatedNumber));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Number copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No number to copy.')));
    }
  }

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Random Number Generator',
        helpContentKey:
            'RANDOM_NUMBER_GENERATOR_TOOL', // Will add this to AppConstants
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
                      Icons.numbers,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Number Length',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter length of digits (e.g., 10)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Generate Number',
                      onPressed: () => _generateNumber(),
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
                      Icons.looks_one,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Number',
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
                        _generatedNumber,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}

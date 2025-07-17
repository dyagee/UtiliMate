// lib/screens/generators/range_number_picker_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For random number generation
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class RangeNumberPickerScreen extends StatefulWidget {
  const RangeNumberPickerScreen({super.key});

  @override
  State<RangeNumberPickerScreen> createState() =>
      _RangeNumberPickerScreenState();
}

class _RangeNumberPickerScreenState extends State<RangeNumberPickerScreen> {
  final TextEditingController _rangeController = TextEditingController(
    text: '100',
  ); // Default max range 100
  String _pickedNumber = 'Tap "Pick Number" to get a random number.';
  String? _errorMessage;
  final Random _random = Random();

  void _pickNumber() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    final int? maxRange = int.tryParse(_rangeController.text);

    if (maxRange == null || maxRange <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid positive maximum range.';
        _pickedNumber = '';
      });
      return;
    }
    if (maxRange > 10000000) {
      // Limit for very large numbers
      setState(() {
        _errorMessage =
            'Maximum range cannot exceed 10,000,000 for performance.';
        _pickedNumber = '';
      });
      return;
    }

    // Generate a random number between 1 and maxRange (inclusive)
    final int number = _random.nextInt(maxRange) + 1;

    setState(() {
      _pickedNumber = number.toString();
    });
  }

  void _copyToClipboard() {
    if (_pickedNumber.isNotEmpty &&
        _pickedNumber != 'Tap "Pick Number" to get a random number.') {
      Clipboard.setData(ClipboardData(text: _pickedNumber));
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
    _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Range Number Picker',
        helpContentKey:
            'RANGE_NUMBER_PICKER_TOOL', // Will add this to AppConstants
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
                      Icons.looks_one_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Maximum Range (from 1 to...)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rangeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter maximum number (e.g., 100)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Pick Number',
                      onPressed: () => _pickNumber(),
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
                      Icons.casino,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Picked Number',
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
                        _pickedNumber,
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

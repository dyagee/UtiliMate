// lib/screens/generators/fake_address_generator_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For random number generation
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class FakeAddressGeneratorScreen extends StatefulWidget {
  const FakeAddressGeneratorScreen({super.key});

  @override
  State<FakeAddressGeneratorScreen> createState() =>
      _FakeAddressGeneratorScreenState();
}

class _FakeAddressGeneratorScreenState
    extends State<FakeAddressGeneratorScreen> {
  final Random _random = Random();
  String _generatedAddress = 'Tap "Generate Address" to get a random address.';

  // Predefined lists for address components
  static const List<String> _streetNames = [
    'Main',
    'Oak',
    'Pine',
    'Maple',
    'Elm',
    'Cedar',
    'Willow',
    'Birch',
    'Park',
    'Church',
    'High',
    'First',
    'Second',
    'Third',
    'Cherry',
    'Garden',
  ];
  static const List<String> _streetTypes = [
    'St',
    'Ave',
    'Rd',
    'Ln',
    'Ct',
    'Dr',
    'Pl',
    'Blvd',
  ];
  static const List<String> _cities = [
    'Springfield',
    'Rivertown',
    'Maplewood',
    'Fairview',
    'Lakeside',
    'Greenville',
    'Oakville',
    'Pleasantville',
    'Centerville',
    'Northwood',
    'Southport',
    'Westbrook',
  ];
  static const List<String> _states = [
    'CA',
    'NY',
    'TX',
    'FL',
    'IL',
    'PA',
    'OH',
    'GA',
    'NC',
    'MI',
    'NJ',
    'VA',
  ]; // US States for simplicity
  static const List<String> _countries = [
    'USA',
    'Canada',
    'UK',
    'Australia',
    'Germany',
    'France',
  ];

  String _generateRandomDigits(int length) {
    return List.generate(length, (_) => _random.nextInt(10)).join();
  }

  void _generateAddress() {
    final String houseNumber = (_random.nextInt(999) + 1).toString(); // 1-999
    final String streetName =
        _streetNames[_random.nextInt(_streetNames.length)];
    final String streetType =
        _streetTypes[_random.nextInt(_streetTypes.length)];
    final String city = _cities[_random.nextInt(_cities.length)];
    final String state = _states[_random.nextInt(_states.length)];
    final String zipCode = _generateRandomDigits(5); // 5-digit zip code
    final String country = _countries[_random.nextInt(_countries.length)];

    setState(() {
      _generatedAddress =
          '$houseNumber $streetName $streetType\n$city, $state $zipCode\n$country';
    });
  }

  void _copyToClipboard() {
    if (_generatedAddress.isNotEmpty &&
        _generatedAddress !=
            'Tap "Generate Address" to get a random address.') {
      Clipboard.setData(ClipboardData(text: _generatedAddress));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No address to copy.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fake Address Generator',
        helpContentKey:
            'FAKE_ADDRESS_GENERATOR_TOOL', // Will add this to AppConstants
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
                      Icons.location_on,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generate a Random Address',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Generate Address',
                      onPressed: () => _generateAddress(),
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
                      Icons.home,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Address',
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
                        _generatedAddress,
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

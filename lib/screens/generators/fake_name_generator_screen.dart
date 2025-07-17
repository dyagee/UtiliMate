// lib/screens/generators/fake_name_generator_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For random number generation
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class FakeNameGeneratorScreen extends StatefulWidget {
  const FakeNameGeneratorScreen({super.key});

  @override
  State<FakeNameGeneratorScreen> createState() =>
      _FakeNameGeneratorScreenState();
}

class _FakeNameGeneratorScreenState extends State<FakeNameGeneratorScreen> {
  final Random _random = Random();
  String _generatedName = 'Tap "Generate Name" to get a random name.';

  // Predefined lists of common first and last names
  static const List<String> _firstNames = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Frank',
    'Grace',
    'Heidi',
    'Ivan',
    'Judy',
    'Kevin',
    'Linda',
    'Mike',
    'Nancy',
    'Oscar',
    'Peggy',
    'Quinn',
    'Rachel',
    'Steve',
    'Tina',
    'Uma',
    'Victor',
    'Wendy',
    'Xavier',
    'Yara',
    'Zane',
    'Olivia',
    'Liam',
    'Emma',
    'Noah',
    'Ava',
    'Elijah',
    'Charlotte',
    'James',
    'Amelia',
    'Benjamin',
    'Sophia',
    'Lucas',
    'Isabella',
    'Mason',
    'Mia',
    'Ethan',
    'Harper',
    'Alexander',
    'Evelyn',
    'William',
    'Abigail',
  ];

  static const List<String> _lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
    'Wilson',
    'Anderson',
    'Thomas',
    'Taylor',
    'Moore',
    'Jackson',
    'Martin',
    'Lee',
    'Perez',
    'Thompson',
    'White',
    'Harris',
    'Sanchez',
    'Clark',
    'Ramirez',
    'Lewis',
    'Robinson',
    'Walker',
  ];

  void _generateName() {
    final String firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final String lastName = _lastNames[_random.nextInt(_lastNames.length)];
    setState(() {
      _generatedName = '$firstName $lastName';
    });
  }

  void _copyToClipboard() {
    if (_generatedName.isNotEmpty &&
        _generatedName != 'Tap "Generate Name" to get a random name.') {
      Clipboard.setData(ClipboardData(text: _generatedName));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No name to copy.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fake Name Generator',
        helpContentKey:
            'FAKE_NAME_GENERATOR_TOOL', // Will add this to AppConstants
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
                      Icons.person_add,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generate a Random Name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Generate Name',
                      onPressed: () => _generateName(),
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
                      Icons.badge,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Name',
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
                        // Allows user to select and copy text easily
                        _generatedName,
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

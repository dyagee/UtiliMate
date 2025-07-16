// lib/screens/text_tools/password_generator_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  double _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  final String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  final String _numberChars = '0123456789';
  final String _symbolChars = '!@#\$%^&*()-_+=[]{}|;:,.<>?';

  void _generatePassword() {
    String chars = '';
    if (_includeUppercase) chars += _uppercaseChars;
    if (_includeLowercase) chars += _lowercaseChars;
    if (_includeNumbers) chars += _numberChars;
    if (_includeSymbols) chars += _symbolChars;

    if (chars.isEmpty) {
      _showSnackBar(
        'Please select at least one character type.',
        isError: true,
      );
      setState(() {
        _generatedPassword = '';
      });
      return;
    }

    final Random random = Random();
    String password = '';
    for (int i = 0; i < _passwordLength.round(); i++) {
      password += chars[random.nextInt(chars.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      _showSnackBar('Password copied to clipboard!');
    } else {
      _showSnackBar('No password generated yet.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _generatePassword(); // Generate initial password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Password Generator',
        helpContentKey: 'PASSWORD_GENERATOR',
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
                      Icons.lock,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Password',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _generatedPassword,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Copy Password',
                      onPressed: _copyToClipboard,
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
                      Icons.tune,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Password Options',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text('Length: ${_passwordLength.round()}'),
                      subtitle: Slider(
                        value: _passwordLength,
                        min: 4,
                        max: 32,
                        divisions: 28,
                        label: _passwordLength.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _passwordLength = value;
                          });
                        },
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Include Uppercase (A-Z)'),
                      value: _includeUppercase,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeUppercase = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Lowercase (a-z)'),
                      value: _includeLowercase,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeLowercase = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Numbers (0-9)'),
                      value: _includeNumbers,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeNumbers = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Symbols (!@#\$)'),
                      value: _includeSymbols,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeSymbols = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Generate New Password',
                      onPressed: _generatePassword,
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

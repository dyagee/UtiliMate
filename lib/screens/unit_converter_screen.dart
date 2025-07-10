import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:utilimate/utils/unit_converter_utils.dart'; // New import
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  UnitCategory _selectedCategory = UnitCategory.length;
  String? _fromUnit;
  String? _toUnit;
  final TextEditingController _inputValueController = TextEditingController();
  String _result = '';

  @override
  void initState() {
    super.initState();
    _updateUnitsForCategory();
  }

  void _updateUnitsForCategory() {
    final units = UnitConverter.getUnitsForCategory(_selectedCategory);
    setState(() {
      _fromUnit = units.isNotEmpty ? units.first : null;
      _toUnit = units.isNotEmpty ? units.first : null;
      _result = ''; // Clear result on category change
    });
  }

  void _performConversion() {
    final double? inputValue = double.tryParse(_inputValueController.text);

    if (inputValue == null) {
      _showSnackBar('Please enter a valid number.', isError: true);
      return;
    }
    if (_fromUnit == null || _toUnit == null) {
      _showSnackBar('Please select both "From" and "To" units.', isError: true);
      return;
    }

    final convertedValue = UnitConverter.convert(
      inputValue,
      _fromUnit!,
      _toUnit!,
      _selectedCategory,
    );

    setState(() {
      if (convertedValue != null) {
        _result =
            '${convertedValue.toStringAsFixed(6)} $_toUnit'; // Format to 6 decimal places
      } else {
        _result = 'Conversion Error';
      }
    });
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
  void dispose() {
    _inputValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableUnits = UnitConverter.getUnitsForCategory(
      _selectedCategory,
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Unit Converter',
        helpContentKey: 'UNIT_CONVERTER',
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
                      Icons.category,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UnitCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          UnitCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                UnitConverter.getCategoryName(category),
                              ),
                            );
                          }).toList(),
                      onChanged: (UnitCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                          _updateUnitsForCategory();
                        }
                      },
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
                      Icons.input,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Input Value',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _inputValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d*'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Value to convert',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _fromUnit,
                      decoration: const InputDecoration(
                        labelText: 'From Unit',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          availableUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _fromUnit = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _toUnit,
                      decoration: const InputDecoration(
                        labelText: 'To Unit',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          availableUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _toUnit = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Convert',
                      onPressed: _performConversion,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Result:',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              // Allows copying the result
                              _result.isNotEmpty
                                  ? _result
                                  : 'Enter values and convert',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

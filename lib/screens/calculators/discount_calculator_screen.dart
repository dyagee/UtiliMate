// lib/screens/calculators/discount_calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController();

  double _discountedPrice = 0.0;
  double _amountSaved = 0.0;
  String? _errorMessage;

  // Formatter for currency display
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    // locale: 'en_US', // Use US locale for dollar sign and comma separators
    // symbol: '\$', // Explicitly set dollar symbol
    decimalDigits: 2, // Ensure two decimal places
  );

  void _calculateDiscount() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    final double? originalPrice = double.tryParse(
      _originalPriceController.text,
    );
    final double? discountPercentage = double.tryParse(
      _discountPercentageController.text,
    );

    if (originalPrice == null || originalPrice <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid original price.';
        _discountedPrice = 0.0;
        _amountSaved = 0.0;
      });
      return;
    }

    if (discountPercentage == null ||
        discountPercentage < 0 ||
        discountPercentage > 100) {
      setState(() {
        _errorMessage = 'Please enter a valid discount percentage (0-100).';
        _discountedPrice = 0.0;
        _amountSaved = 0.0;
      });
      return;
    }

    // Calculate discounted price
    _amountSaved = originalPrice * (discountPercentage / 100);
    _discountedPrice = originalPrice - _amountSaved;

    setState(() {
      _discountedPrice = _discountedPrice;
      _amountSaved = _amountSaved;
    });
  }

  @override
  void dispose() {
    _originalPriceController.dispose();
    _discountPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Discount Calculator',
        helpContentKey:
            'DISCOUNT_CALCULATOR_TOOL', // Will add this to AppConstants
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
                      Icons.attach_money,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Original Price',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _originalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Original Price',
                        border: OutlineInputBorder(),
                        prefixText: '#', // Add dollar sign prefix
                      ),
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
                      Icons.percent,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discount Percentage',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _discountPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Discount %',
                        border: OutlineInputBorder(),
                        suffixText: '%', // Add percentage suffix
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Calculate Discount',
                      onPressed: () => _calculateDiscount(),
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
                      Icons.receipt_long,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Results',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discounted Price: #${_currencyFormatter.format(_discountedPrice)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amount Saved: #${_currencyFormatter.format(_amountSaved)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
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

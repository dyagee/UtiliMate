// lib/screens/currency_converter_screen.dart
import 'package:flutter/material.dart';
import 'package:utilimate/services/currency_service.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/widgets/loading_indicator.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController();

  List<String> _currencies = [];
  String? _fromCurrency;
  String? _toCurrency;
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<String> fetchedCurrencies =
          await _currencyService.fetchSupportedCurrencies();
      setState(() {
        _currencies = fetchedCurrencies;
        if (_currencies.isNotEmpty) {
          _fromCurrency =
              _currencies.contains('USD') ? 'USD' : _currencies.first;
          _toCurrency = _currencies.contains('NGN') ? 'NGN' : _currencies.last;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load currencies: ${e.toString()}';
      });
      _showSnackBar(_errorMessage!, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_fromCurrency == null ||
        _toCurrency == null ||
        _amountController.text.isEmpty) {
      _showSnackBar(
        'Please select currencies and enter an amount.',
        isError: true,
      );
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid positive amount.', isError: true);
      return;
    }

    if (_fromCurrency == _toCurrency) {
      setState(() {
        _convertedAmount = amount;
      });
      _showSnackBar('Same currency selected. No conversion needed.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, double> rates = await _currencyService
          .fetchExchangeRates(_fromCurrency!);
      if (rates.containsKey(_toCurrency)) {
        final double rate = rates[_toCurrency]!;
        setState(() {
          _convertedAmount = amount * rate;
        });
        _showSnackBar('Conversion successful!');
      } else {
        setState(() {
          _errorMessage =
              'Exchange rate for $_toCurrency not available (from $_fromCurrency).';
          _convertedAmount = 0.0;
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error converting currency: ${e.toString()}';
        _convertedAmount = 0.0;
      });
      _showSnackBar(_errorMessage!, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final String? temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convertedAmount = 0.0; // Reset converted amount
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = _isLoading || _currencies.isEmpty;

    // Corrected: Use NumberFormat.decimalPattern for reliable grouping
    // It will format with commas and respect locale's decimal separator.
    // For exactly two decimal places, we can set minimumFractionDigits and maximumFractionDigits.
    final NumberFormat currencyFormatter =
        NumberFormat.decimalPattern('en_US')
          ..minimumFractionDigits = 2
          ..maximumFractionDigits = 2;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Currency Converter',
        helpContentKey: 'CURRENCY_CONVERTER_TOOL',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          Icons.money,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Amount to Convert',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !isDisabled,
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
                          Icons.currency_exchange,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select Currencies',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _fromCurrency,
                                decoration: const InputDecoration(
                                  labelText: 'From',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _currencies.map((String currency) {
                                      return DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      );
                                    }).toList(),
                                onChanged:
                                    isDisabled
                                        ? null
                                        : (String? newValue) {
                                          setState(() {
                                            _fromCurrency = newValue;
                                            _convertedAmount = 0.0;
                                          });
                                        },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.swap_horiz,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed:
                                  isDisabled ? null : () => _swapCurrencies(),
                              tooltip: 'Swap Currencies',
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _toCurrency,
                                decoration: const InputDecoration(
                                  labelText: 'To',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _currencies.map((String currency) {
                                      return DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      );
                                    }).toList(),
                                onChanged:
                                    isDisabled
                                        ? null
                                        : (String? newValue) {
                                          setState(() {
                                            _toCurrency = newValue;
                                            _convertedAmount = 0.0;
                                          });
                                        },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Convert',
                          onPressed:
                              isDisabled ? null : () => _convertCurrency(),
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
                          Icons.paid,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Converted Amount',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                          child: Text(
                            '${currencyFormatter.format(_convertedAmount)} ${_toCurrency ?? ''}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}

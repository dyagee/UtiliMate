// lib/services/currency_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // New import

class CurrencyService {
  // IMPORTANT: Replace 'YOUR_API_KEY' with your actual API key from openexchangerates.org
  // You can get a free API key by signing up at https://openexchangerates.org/signup/free
  static const String _apiKey =
      '60b208ac73284be1b68c24db5db2a071'; // <<< REPLACE THIS WITH YOUR ACTUAL API KEY
  static const String _baseUrl = 'https://openexchangerates.org/api';

  // Cache keys
  static const String _currenciesCacheKey = 'supportedCurrencies';
  static const String _currenciesTimestampKey = 'supportedCurrenciesTimestamp';
  static const String _ratesCachePrefix =
      'exchangeRates_'; // Prefix for base currency rates
  static const String _ratesTimestampPrefix = 'exchangeRatesTimestamp_';

  // Cache validity duration (e.g., 1 hour for hourly updates)
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Fetches a list of supported currency codes (e.g., USD, EUR, NGN).
  /// Uses caching to minimize API calls.
  Future<List<String>> fetchSupportedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();

    // Check cache
    final String? cachedCurrenciesJson = prefs.getString(_currenciesCacheKey);
    final int? cachedTimestampMillis = prefs.getInt(_currenciesTimestampKey);

    if (cachedCurrenciesJson != null && cachedTimestampMillis != null) {
      final DateTime cachedTime = DateTime.fromMillisecondsSinceEpoch(
        cachedTimestampMillis,
      );
      if (DateTime.now().difference(cachedTime) < _cacheDuration) {
        print('Returning cached supported currencies.');
        return List<String>.from(json.decode(cachedCurrenciesJson));
      }
    }

    // Cache is old or doesn't exist, fetch from API
    final uri = Uri.parse('$_baseUrl/currencies.json?app_id=$_apiKey');
    try {
      print('Fetching supported currencies from API...');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<String> currencies = data.keys.toList().cast<String>();
        currencies.sort(); // Sort alphabetically for consistent display

        // Cache the new data and timestamp
        await prefs.setString(_currenciesCacheKey, json.encode(currencies));
        await prefs.setInt(
          _currenciesTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        print('Successfully fetched and cached supported currencies.');
        return currencies;
      } else {
        throw Exception(
          'Failed to load supported currencies: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching supported currencies from API: $e');
      // If API fails, try to return stale cache if available
      if (cachedCurrenciesJson != null) {
        print('API failed, returning stale cached supported currencies.');
        return List<String>.from(json.decode(cachedCurrenciesJson));
      }
      rethrow; // Re-throw if no cache available
    }
  }

  /// Fetches exchange rates for a given base currency.
  /// Uses caching to minimize API calls.
  Future<Map<String, double>> fetchExchangeRates(String baseCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    final String ratesCacheKey = '$_ratesCachePrefix$baseCurrency';
    final String ratesTimestampKey = '$_ratesTimestampPrefix$baseCurrency';

    // Check cache
    final String? cachedRatesJson = prefs.getString(ratesCacheKey);
    final int? cachedTimestampMillis = prefs.getInt(ratesTimestampKey);

    if (cachedRatesJson != null && cachedTimestampMillis != null) {
      final DateTime cachedTime = DateTime.fromMillisecondsSinceEpoch(
        cachedTimestampMillis,
      );
      if (DateTime.now().difference(cachedTime) < _cacheDuration) {
        print('Returning cached exchange rates for $baseCurrency.');
        return Map<String, double>.from(
          json
              .decode(cachedRatesJson)
              .map((key, value) => MapEntry(key, value.toDouble())),
        );
      }
    }

    // Cache is old or doesn't exist, fetch from API
    // Open Exchange Rates 'latest' endpoint returns rates relative to USD by default for free tier.
    // If you need other base currencies, you'd need a paid plan or convert client-side.
    // For simplicity with the free tier, we'll assume USD as base for fetching,
    // and then convert client-side if a different base is selected.
    final uri = Uri.parse('$_baseUrl/latest.json?app_id=$_apiKey');
    try {
      print('Fetching exchange rates for $baseCurrency from API...');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['rates'] != null) {
          final Map<String, double> fetchedRates = Map<String, double>.from(
            data['rates'].map((key, value) => MapEntry(key, value.toDouble())),
          );

          // If the requested baseCurrency is not USD (the free tier's default base),
          // we need to perform client-side conversion to get rates relative to the selected base.
          if (baseCurrency != data['base']) {
            if (fetchedRates.containsKey(baseCurrency)) {
              final double usdToBaseRate = fetchedRates[baseCurrency]!;
              if (usdToBaseRate != 0) {
                // Avoid division by zero
                final Map<String, double> convertedRates = {};
                fetchedRates.forEach((targetCurrency, usdToTargetRate) {
                  convertedRates[targetCurrency] =
                      usdToTargetRate / usdToBaseRate;
                });
                // Cache the client-side converted rates for the specific baseCurrency
                await prefs.setString(
                  ratesCacheKey,
                  json.encode(convertedRates),
                );
                await prefs.setInt(
                  ratesTimestampKey,
                  DateTime.now().millisecondsSinceEpoch,
                );
                print(
                  'Successfully fetched USD rates, converted to $baseCurrency, and cached.',
                );
                return convertedRates;
              } else {
                throw Exception('Cannot convert: base currency rate is zero.');
              }
            } else {
              throw Exception(
                'Base currency $baseCurrency not found in fetched rates.',
              );
            }
          } else {
            // If baseCurrency is USD, cache directly
            await prefs.setString(ratesCacheKey, json.encode(fetchedRates));
            await prefs.setInt(
              ratesTimestampKey,
              DateTime.now().millisecondsSinceEpoch,
            );
            print('Successfully fetched and cached USD exchange rates.');
            return fetchedRates;
          }
        } else {
          throw Exception('API response missing "rates" data.');
        }
      } else {
        throw Exception(
          'Failed to load exchange rates: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching exchange rates from API: $e');
      // If API fails, try to return stale cache if available
      if (cachedRatesJson != null) {
        print(
          'API failed, returning stale cached exchange rates for $baseCurrency.',
        );
        return Map<String, double>.from(
          json
              .decode(cachedRatesJson)
              .map((key, value) => MapEntry(key, value.toDouble())),
        );
      }
      rethrow; // Re-throw if no cache available
    }
  }
}

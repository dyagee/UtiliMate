import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:faker_dart/faker_dart.dart'; // Import faker_dart
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/services/ad_manager.dart'; // Import AdManager
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads

class FakeAddressGeneratorScreen extends StatefulWidget {
  const FakeAddressGeneratorScreen({super.key});

  @override
  State<FakeAddressGeneratorScreen> createState() =>
      _FakeAddressGeneratorScreenState();
}

class _FakeAddressGeneratorScreenState
    extends State<FakeAddressGeneratorScreen> {
  String _generatedAddress = '';
  String? _selectedCountry;
  AdWidget? _bannerAdWidget; // Variable to hold the AdWidget

  late final Faker _faker;

  static const Map<String, FakerLocaleType> _countryToLocale = {
    'United States': FakerLocaleType.en_US,
    'Canada': FakerLocaleType.en_CA,
    'United Kingdom': FakerLocaleType.en_GB,
    'France': FakerLocaleType.fr,
    'Spain': FakerLocaleType.es,
    'Germany': FakerLocaleType.de,
    'Japan': FakerLocaleType.ja,
    'Turkey': FakerLocaleType.tr,
    'Vietnam': FakerLocaleType.vi,
    'Sweden': FakerLocaleType.sv,
    'Russia': FakerLocaleType.ru,
    'Finland': FakerLocaleType.fi,
    'Czech Republic': FakerLocaleType.cz,
  };

  @override
  void initState() {
    super.initState();
    _faker = Faker.instance;
    _selectedCountry = 'United States';
    _faker.setLocale(
      _countryToLocale[_selectedCountry!] ?? FakerLocaleType.en_US,
    );
    _generateAddress();

    // Initialize the banner ad widget
    _bannerAdWidget = AdManager().getBannerAdWidget();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _bannerAdWidget = AdManager().getBannerAdWidget();
        });
      }
    });
  }

  void _generateAddress() {
    setState(() {
      FakerLocaleType effectiveLocale =
          _countryToLocale[_selectedCountry!] ?? FakerLocaleType.en_US;
      _faker.setLocale(effectiveLocale);

      _generatedAddress =
          '${_faker.address.streetAddress()}\n'
          '${_faker.address.city()}, ${_faker.address.state()} ${_faker.address.zipCode()}\n'
          '${_selectedCountry!}';
    });
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
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
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fake Address Generator',
        helpContentKey: 'FAKE_ADDRESS_GENERATOR_TOOL',
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
                      Icons.location_city,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generate Addresses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Country Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Country'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      },
                      isExpanded: true,
                      items:
                          _countryToLocale.keys
                              .toList()
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              })
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _generateAddress,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Address'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_generatedAddress.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated Address:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        width: double.infinity,
                        child: Text(
                          _generatedAddress,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(_generatedAddress),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy to Clipboard'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
      bottomNavigationBar:
          isBannerAdReady
              ? SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: _bannerAdWidget!,
              )
              : null,
    );
  }
}

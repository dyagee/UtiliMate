// lib/screens/generators/fake_address_generator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:faker_dart/faker_dart.dart'; // Import faker_dart
import 'package:utilimate/widgets/custom_app_bar.dart';

class FakeAddressGeneratorScreen extends StatefulWidget {
  const FakeAddressGeneratorScreen({super.key});

  @override
  State<FakeAddressGeneratorScreen> createState() =>
      _FakeAddressGeneratorScreenState();
}

class _FakeAddressGeneratorScreenState
    extends State<FakeAddressGeneratorScreen> {
  String _generatedAddress = '';
  String? _selectedCountry; // Initialized in initState
  // String? _selectedState; // Removed: No longer needed

  late final Faker _faker;

  // Map display country names to FakerLocaleType
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
    // Add other countries as needed, mapping to their respective locales
  };

  // Removed: _statesByCountry is no longer needed as the state dropdown is removed.
  // static const Map<String, List<String>> _statesByCountry = {
  //   'United States': ['California', 'New York', 'Texas', 'Florida'],
  //   'Canada': ['Ontario', 'Quebec', 'British Columbia'],
  //   'United Kingdom': ['England', 'Scotland', 'Wales'],
  //   'France': ['Île-de-France', 'Occitanie', 'Provence-Alpes-Côte d\'Azur'],
  //   'Spain': ['Andalusia', 'Catalonia', 'Madrid'],
  //   'Germany': ['Bavaria', 'North Rhine-Westphalia', 'Berlin'],
  //   'Japan': ['Tokyo', 'Osaka', 'Kyoto'],
  //   'Turkey': ['Istanbul', 'Ankara', 'Izmir'],
  //   'Vietnam': ['Hanoi', 'Ho Chi Minh City', 'Da Nang'],
  //   'Sweden': ['Stockholm', 'Västra Götaland', 'Skåne'],
  //   'Russia': ['Moscow Oblast', 'Saint Petersburg', 'Krasnodar Krai'],
  //   'Finland': ['Uusimaa', 'Pirkanmaa', 'Southwest Finland'],
  //   'Czech Republic': ['Prague', 'Central Bohemia', 'South Moravian'],
  // };

  @override
  void initState() {
    super.initState();
    _faker = Faker.instance;
    // Initialize _selectedCountry with a default value
    _selectedCountry = 'United States';
    // Set initial locale for faker_dart based on the default selected country
    _faker.setLocale(
      _countryToLocale[_selectedCountry!] ?? FakerLocaleType.en_US,
    );
    _generateAddress(); // Generate a default address on init
  }

  void _generateAddress() {
    setState(() {
      FakerLocaleType effectiveLocale =
          _countryToLocale[_selectedCountry!] ??
          FakerLocaleType.en_US; // Now guaranteed non-null
      _faker.setLocale(effectiveLocale); // Set the locale for faker

      // FakerDart will automatically generate a state/province appropriate
      // for the set locale.
      _generatedAddress =
          '${_faker.address.streetAddress()}\n'
          '${_faker.address.city()}, ${_faker.address.state()} ${_faker.address.zipCode()}\n'
          '${_selectedCountry!}'; // Use the selected country directly to ensure consistency
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
    // Removed: statesForSelectedCountry is no longer needed
    // List<String> statesForSelectedCountry =
    //     _statesByCountry[_selectedCountry ?? 'United States'] ?? [];

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
                      value:
                          _selectedCountry, // Now initialized to 'United States'
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                      // Removed default from hint, value will be displayed
                      hint: const Text('Select Country'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                          // Removed: _selectedState = null; no longer needed
                        });
                      },
                      isExpanded: true, // Keep isExpanded: true
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
                    const SizedBox(
                      height: 24,
                    ), // Increased spacing after country dropdown
                    // Removed: State/Region (Simulated) Dropdown
                    // DropdownButtonFormField<String>(
                    //   value: _selectedState,
                    //   decoration: const InputDecoration(
                    //     labelText: 'State/Region (Simulated)',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   hint: const Text('Select State/Region (Optional)'),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _selectedState = newValue;
                    //     });
                    //   },
                    //   isExpanded: true,
                    //   items: statesForSelectedCountry
                    //       .map<DropdownMenuItem<String>>((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value, overflow: TextOverflow.ellipsis),
                    //     );
                    //   }).toList(),
                    //   isDense: true,
                    // ),
                    // const SizedBox(height: 24), // Spacing after state dropdown, if present
                    ElevatedButton.icon(
                      onPressed: _generateAddress,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Address'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          50,
                        ), // Full width button
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
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .onSurface, // Assuming onSurface is appropriate for contrast
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
                          minimumSize: const Size.fromHeight(
                            50,
                          ), // Full width button
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
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';
import 'package:utilimate/services/ad_manager.dart'; // Import AdManager
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads

class RandomTextGeneratorScreen extends StatefulWidget {
  const RandomTextGeneratorScreen({super.key});

  @override
  State<RandomTextGeneratorScreen> createState() =>
      _RandomTextGeneratorScreenState();
}

class _RandomTextGeneratorScreenState extends State<RandomTextGeneratorScreen> {
  final TextEditingController _paragraphCountController = TextEditingController(
    text: '3',
  );
  String _generatedText = 'Tap "Generate Text" to get random paragraphs.';
  String? _errorMessage;
  AdWidget? _bannerAdWidget;

  // Map to hold different language texts with more verbose content
  final Map<String, String> _languageData = {
    'Lorem Ipsum':
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, turpis. Aliquam erat volutpat. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, turpis. Aliquam erat volutpat. Aliquam erat volutpat. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, turpis. Aliquam erat volutpat. Aliquam erat volutpat. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, turpis. Aliquam erat volutpat.",
    'English':
        "In the vast expanse of the digital age, communication has evolved beyond simple words to encompass a rich tapestry of media. From short messages to elaborate multimedia presentations, the way we connect and share information has become more dynamic and integrated than ever before. It is a world where every click, every tap, and every keystroke contributes to a larger conversation, building bridges across cultures and continents. The journey from a simple idea to a globally recognized phenomenon is often paved with a multitude of small, incremental steps. Each one, a brick in the foundation, contributes to the overall structure and resilience of the project. Whether it's a new software application, a creative piece of art, or a scientific breakthrough, the process of creation is a testament to human ingenuity and perseverance. The sun dipped below the horizon, painting the sky in hues of orange, pink, and purple. The day's work was done, and the world seemed to slow down for a moment of quiet reflection. It was a perfect ending to a productive day, a moment to appreciate the beauty of the natural world before the stars began to emerge one by one, lighting up the night sky in a brilliant display of cosmic grandeur.",
    'Spanish':
        "El veloz murciélago hindú comía feliz cardillo y kiwi. El pingüino Wamba se cruzó con un hombre de jerséis. La cigüeña tocaba el saxofón detrás del palenque de paja. El pingüino es un ave que no vuela. El veloz murciélago volaba muy rápido por el aire. Un hombre de jerséis se cruzó por el camino. La cigüeña es una gran ave con pico y patas largas. Las aves del corral eran muy ruidosas. El pingüino es un animal marino. La cigüeña tocó el saxofón. El veloz murciélago hindú comía feliz cardillo y kiwi. El pingüino Wamba se cruzó con un hombre de jerséis. La cigüeña tocaba el saxofón detrás del palenque de paja. El pingüino es un ave que no vuela. El veloz murciélago volaba muy rápido por el aire. Un hombre de jerséis se cruzó por el camino. La cigüeña es una gran ave con pico y patas largas. Las aves del corral eran muy ruidosas. El pingüino es un animal marino. La cigüeña tocó el saxofón. El veloz murciélago hindú comía feliz cardillo y kiwi. El pingüino Wamba se cruzó con un hombre de jerséis. La cigüeña tocaba el saxofón detrás del palenque de paja. El pingüino es un ave que no vuela. El veloz murciélago volaba muy rápido por el aire. Un hombre de jerséis se cruzó por el camino. La cigüeña es una gran ave con pico y patas largas. Las aves del corral eran muy ruidosas. El pingüino es un animal marino. La cigüeña tocó el saxofón.",
    'French':
        "Portez ce vieux whisky au juge blond qui fume. La rime est souvent une expression de l'âme. Ce jour-là, l'air était froid et sec. Le grand cheval noir galopait dans les champs. Les oiseaux chantaient joyeusement au lever du soleil. Le vent soufflait doucement sur les arbres. L'océan Atlantique est un vaste espace. La vie est une question de choix. Les enfants jouaient ensemble dans le parc. Le soleil se couchait lentement à l'horizon. La nuit étoilée était magnifique à regarder. Le chat se promenait sur les toits. Le café était chaud et délicieux. Les montagnes semblaient si majestueuses. Portez ce vieux whisky au juge blond qui fume. La rime est souvent une expression de l'âme. Ce jour-là, l'air était froid et sec. Le grand cheval noir galopait dans les champs. Les oiseaux chantaient joyeusement au lever du soleil. Le vent soufflait doucement sur les arbres. L'océan Atlantique est un vaste espace. La vie est une question de choix. Les enfants jouaient ensemble dans le parc. Le soleil se couchait lentement à l'horizon. La nuit étoilée était magnifique à regarder. Le chat se promenait sur les toits. Le café était chaud et délicieux. Les montagnes semblaient si majestueuses.",
  };

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Set initial language to 'Lorem Ipsum' as the default
    _selectedLanguage = 'Lorem Ipsum';
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

  void _generateText() {
    setState(() {
      _errorMessage = null;
    });

    final int? paragraphCount = int.tryParse(_paragraphCountController.text);

    if (paragraphCount == null || paragraphCount <= 0) {
      setState(() {
        _errorMessage =
            'Please enter a valid number of paragraphs (e.g., 1-10).';
        _generatedText = '';
      });
      return;
    }

    // Get the text content based on the selected language
    final String textContent = _languageData[_selectedLanguage]!;

    final List<String> paragraphs = textContent.split(
      '. ',
    ); // Split into sentences/phrases
    final StringBuffer generatedBuffer = StringBuffer();
    final Random random = Random();

    for (int i = 0; i < paragraphCount; i++) {
      int sentenceCount = random.nextInt(5) + 3; // 3-7 sentences per paragraph
      for (int j = 0; j < sentenceCount; j++) {
        generatedBuffer.write(paragraphs[random.nextInt(paragraphs.length)]);
        if (j < sentenceCount - 1) {
          generatedBuffer.write('. '); // Re-add period and space
        }
      }
      generatedBuffer.write(
        '.\n\n',
      ); // End paragraph with period and two newlines
    }

    setState(() {
      _generatedText =
          generatedBuffer.toString().trim(); // Remove trailing newlines
    });
  }

  void _copyToClipboard() {
    if (_generatedText.isNotEmpty &&
        _generatedText != 'Tap "Generate Text" to get random paragraphs.') {
      Clipboard.setData(ClipboardData(text: _generatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No text to copy.')));
    }
  }

  @override
  void dispose() {
    _paragraphCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Random Text Generator',
        helpContentKey: 'RANDOM_TEXT_GENERATOR_TOOL',
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
                      Icons.text_format,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Language & Paragraphs',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Language selection dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Select Language',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _languageData.keys
                              .map(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _paragraphCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter number of paragraphs (e.g., 1-10)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Generate Text',
                      onPressed: () => _generateText(),
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
                      Icons.description,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generated Text',
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
                        _generatedText,
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

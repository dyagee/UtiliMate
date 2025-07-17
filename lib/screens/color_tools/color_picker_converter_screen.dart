// lib/screens/color_tools/color_picker_converter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';

class ColorPickerConverterScreen extends StatefulWidget {
  const ColorPickerConverterScreen({super.key});

  @override
  State<ColorPickerConverterScreen> createState() =>
      _ColorPickerConverterScreenState();
}

class _ColorPickerConverterScreenState
    extends State<ColorPickerConverterScreen> {
  // Current color values
  Color _currentColor = Colors.red;
  String _hexValue = 'FF0000'; // Default for red
  late TextEditingController _hexController;
  late TextEditingController _rgbRController;
  late TextEditingController _rgbGController;
  late TextEditingController _rgbBController;
  late TextEditingController _hslHController;
  late TextEditingController _hslSController;
  late TextEditingController _hslLController;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _hexController = TextEditingController(text: 'FF0000');
    _rgbRController = TextEditingController(text: '255');
    _rgbGController = TextEditingController(text: '0');
    _rgbBController = TextEditingController(text: '0');
    _hslHController = TextEditingController(text: '0');
    _hslSController = TextEditingController(text: '100');
    _hslLController = TextEditingController(text: '50');

    // Add listeners to controllers for user input changes
    _hexController.addListener(_onHexInputChanged);
    _rgbRController.addListener(_onRgbInputChanged);
    _rgbGController.addListener(_onRgbInputChanged);
    _rgbBController.addListener(_onRgbInputChanged);
    _hslHController.addListener(_onHslInputChanged);
    _hslSController.addListener(_onHslInputChanged);
    _hslLController.addListener(_onHslInputChanged);

    _updateColorFields(
      Colors.red,
    ); // Initialize all fields based on the initial color
  }

  // --- Color Conversion Logic ---

  // Update all fields based on a new Color object
  // setState is removed from here. This function now only updates the _currentColor and controllers.
  // The setState that rebuilds the UI happens in the callers (slider onChanged or input onChanged).
  void _updateColorFields(Color color) {
    // Temporarily remove listeners to prevent feedback loop during programmatic updates
    _hexController.removeListener(_onHexInputChanged);
    _rgbRController.removeListener(_onRgbInputChanged);
    _rgbGController.removeListener(_onRgbInputChanged);
    _rgbBController.removeListener(_onRgbInputChanged);
    _hslHController.removeListener(_onHslInputChanged);
    _hslSController.removeListener(_onHslInputChanged);
    _hslLController.removeListener(_onHslInputChanged);

    // Update _currentColor directly here.
    // The setState that triggers a rebuild will be in the calling method (e.g., slider's onChanged).
    _currentColor = color;
    _hexValue = _colorToHex(color);

    // Use controller.value.copyWith to update text programmatically without triggering listeners
    if (_hexController.text != _hexValue) {
      _hexController.value = _hexController.value.copyWith(text: _hexValue);
    }

    String newR = color.r.toString();
    String newG = color.g.toString();
    String newB = color.b.toString();

    if (_rgbRController.text != newR) {
      _rgbRController.value = _rgbRController.value.copyWith(text: newR);
    }
    if (_rgbGController.text != newG) {
      _rgbGController.value = _rgbGController.value.copyWith(text: newG);
    }
    if (_rgbBController.text != newB) {
      _rgbBController.value = _rgbBController.value.copyWith(text: newB);
    }

    HSLColor hsl = HSLColor.fromColor(color);
    String newH = hsl.hue.round().toString();
    String newS = (hsl.saturation * 100).round().toString();
    String newL = (hsl.lightness * 100).round().toString();

    if (_hslHController.text != newH) {
      _hslHController.value = _hslHController.value.copyWith(text: newH);
    }
    if (_hslSController.text != newS) {
      _hslSController.value = _hslSController.value.copyWith(text: newS);
    }
    if (_hslLController.text != newL) {
      _hslLController.value = _hslLController.value.copyWith(text: newL);
    }

    // Re-add listeners
    _hexController.addListener(_onHexInputChanged);
    _rgbRController.addListener(_onRgbInputChanged);
    _rgbGController.addListener(_onRgbInputChanged);
    _rgbBController.addListener(_onRgbInputChanged);
    _hslHController.addListener(_onHslInputChanged);
    _hslSController.addListener(_onHslInputChanged);
    _hslLController.addListener(_onHslInputChanged);
  }

  // Convert Color to Hex string (e.g., FF0000)
  String _colorToHex(Color color) {
    return color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  // Convert Hex string to Color object
  Color? _hexToColor(String hex) {
    hex = hex.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }
    if (hex.length == 8) {
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Convert RGB values to Color object
  Color? _rgbToColor(int r, int g, int b) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      return null;
    }
    return Color.fromARGB(255, r, g, b);
  }

  // Convert HSL values to Color object
  Color? _hslToColor(double h, double s, double l) {
    if (h < 0 || h > 360 || s < 0 || s > 100 || l < 0 || l > 100) {
      return null;
    }
    return HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  }

  // --- Input Handlers (triggered by user typing) ---

  void _onHexInputChanged() {
    // Only process if the controller's text is different from the current hex value
    // to avoid unnecessary updates when _updateColorFields sets the text.
    if (_hexController.text == _hexValue) return;

    setState(() {
      _errorMessage = null;
      Color? newColor = _hexToColor(_hexController.text);
      if (newColor != null) {
        _updateColorFields(newColor);
      } else if (_hexController.text.isNotEmpty) {
        _errorMessage = 'Invalid Hex code. Use 6 or 8 digits (e.g., FF0000).';
      }
    });
  }

  void _onRgbInputChanged() {
    String currentR = _currentColor.r.toString();
    String currentG = _currentColor.g.toString();
    String currentB = _currentColor.b.toString();

    // Only process if any of the RGB controller texts are different from current color components
    if (_rgbRController.text == currentR &&
        _rgbGController.text == currentG &&
        _rgbBController.text == currentB) {
      return;
    }

    setState(() {
      _errorMessage = null;
      int? r = int.tryParse(_rgbRController.text);
      int? g = int.tryParse(_rgbGController.text);
      int? b = int.tryParse(_rgbBController.text);

      if (r != null && g != null && b != null) {
        Color? newColor = _rgbToColor(r, g, b);
        if (newColor != null) {
          _updateColorFields(newColor);
        } else {
          _errorMessage = 'RGB values must be between 0 and 255.';
        }
      } else {
        _errorMessage = 'Invalid RGB values. Enter numbers for R, G, B.';
      }
    });
  }

  void _onHslInputChanged() {
    HSLColor currentHsl = HSLColor.fromColor(_currentColor);
    String currentH = currentHsl.hue.round().toString();
    String currentS = (currentHsl.saturation * 100).round().toString();
    String currentL = (currentHsl.lightness * 100).round().toString();

    // Only process if any of the HSL controller texts are different from current color components
    if (_hslHController.text == currentH &&
        _hslSController.text == currentS &&
        _hslLController.text == currentL) {
      return;
    }

    setState(() {
      _errorMessage = null;
      double? h = double.tryParse(_hslHController.text);
      double? s = double.tryParse(_hslSController.text);
      double? l = double.tryParse(_hslLController.text);

      if (h != null && s != null && l != null) {
        Color? newColor = _hslToColor(h, s, l);
        if (newColor != null) {
          _updateColorFields(newColor);
        } else {
          _errorMessage = 'HSL: Hue 0-360, Saturation/Lightness 0-100.';
        }
      } else {
        _errorMessage = 'Invalid HSL values. Enter numbers for H, S, L.';
      }
    });
  }

  // --- Copy to Clipboard ---
  void _copyToClipboard(String text, String format) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$format copied to clipboard!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No $format to copy.')));
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _hexController.removeListener(_onHexInputChanged);
    _rgbRController.removeListener(_onRgbInputChanged);
    _rgbGController.removeListener(_onRgbInputChanged);
    _rgbBController.removeListener(_onRgbInputChanged);
    _hslHController.removeListener(_onHslInputChanged);
    _hslSController.removeListener(_onHslInputChanged);
    _hslLController.removeListener(_onHslInputChanged);

    _hexController.dispose();
    _rgbRController.dispose();
    _rgbGController.dispose();
    _rgbBController.dispose();
    _hslHController.dispose();
    _hslSController.dispose();
    _hslLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Color Picker & Converter',
        helpContentKey: 'COLOR_PICKER_CONVERTER_TOOL',
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
                      Icons.palette,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Color Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Color Preview Box
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Adjust RGB Sliders:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    // RGB Sliders
                    _buildColorSlider(
                      'Red',
                      _currentColor.r.toDouble(),
                      Colors.red,
                      (value) {
                        setState(() {
                          _currentColor = Color.fromARGB(
                            255,
                            value.round(),
                            _currentColor.g.round(), // FIX: Explicitly round
                            _currentColor.b.round(), // FIX: Explicitly round
                          );
                          // Now update the text fields and other parts of the UI
                          _updateColorFields(_currentColor);
                        });
                      },
                    ),
                    _buildColorSlider(
                      'Green',
                      _currentColor.g.toDouble(),
                      Colors.green,
                      (value) {
                        setState(() {
                          _currentColor = Color.fromARGB(
                            255,
                            _currentColor.r.round(), // FIX: Explicitly round
                            value.round(),
                            _currentColor.b.round(), // FIX: Explicitly round
                          );
                          _updateColorFields(_currentColor);
                        });
                      },
                    ),
                    _buildColorSlider(
                      'Blue',
                      _currentColor.b.toDouble(),
                      Colors.blue,
                      (value) {
                        setState(() {
                          _currentColor = Color.fromARGB(
                            255,
                            _currentColor.r.round(), // FIX: Explicitly round
                            _currentColor.g.round(), // FIX: Explicitly round
                            value.round(),
                          );
                          _updateColorFields(_currentColor);
                        });
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
                      Icons.code,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Color Formats',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hex Input & Copy
                    _buildColorFormatInput(
                      label: 'Hex',
                      controller: _hexController,
                      valueToCopy: _hexValue,
                      formatName: 'Hex',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    // RGB Inputs & Copy
                    Row(
                      children: [
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'R',
                            controller: _rgbRController,
                            valueToCopy: _rgbRController.text,
                            formatName: 'RGB R',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'G',
                            controller: _rgbGController,
                            valueToCopy: _rgbGController.text,
                            formatName: 'RGB G',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'B',
                            controller: _rgbBController,
                            valueToCopy: _rgbBController.text,
                            formatName: 'RGB B',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed:
                              () => _copyToClipboard(
                                '${_rgbRController.text},${_rgbGController.text},${_rgbBController.text}',
                                'RGB',
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // HSL Inputs & Copy
                    Row(
                      children: [
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'H',
                            controller: _hslHController,
                            valueToCopy: _hslHController.text,
                            formatName: 'HSL H',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'S (%)',
                            controller: _hslSController,
                            valueToCopy: _hslSController.text,
                            formatName: 'HSL S',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildColorFormatInput(
                            label: 'L (%)',
                            controller: _hslLController,
                            valueToCopy: _hslLController.text,
                            formatName: 'HSL L',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed:
                              () => _copyToClipboard(
                                '${_hslHController.text},${_hslSController.text},${_hslLController.text}',
                                'HSL',
                              ),
                        ),
                      ],
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

  Widget _buildColorSlider(
    String label,
    double value,
    Color activeColor,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 255,
              divisions: 255,
              activeColor: activeColor,
              inactiveColor: activeColor.withAlpha((255 * 0.3).round()),
              onChanged: (newValue) {
                onChanged(newValue);
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.round().toString(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorFormatInput({
    required String label,
    required TextEditingController controller,
    required String valueToCopy,
    required String formatName,
    required TextInputType keyboardType,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            // onChanged is handled by addListener in initState, not here
          ),
        ),
        if (formatName != 'RGB R' &&
            formatName != 'RGB G' &&
            formatName != 'RGB B' &&
            formatName != 'HSL H' &&
            formatName != 'HSL S' &&
            formatName != 'HSL L')
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(valueToCopy, formatName),
          ),
      ],
    );
  }
}

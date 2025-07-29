// lib/screens/color_tools/color_picker_converter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import flutter_colorpicker

class ColorPickerConverterScreen extends StatefulWidget {
  const ColorPickerConverterScreen({super.key});

  @override
  State<ColorPickerConverterScreen> createState() =>
      _ColorPickerConverterScreenState();
}

class _ColorPickerConverterScreenState
    extends State<ColorPickerConverterScreen> {
  Color _currentColor = Colors.red; // Initial color
  String _hexValue = 'FF0000'; // Default for red
  String _rgbValue = '255, 0, 0';
  String _hslValue = '0, 100%, 50%';

  late TextEditingController _hexController;

  String? _errorMessage;

  // Flag to prevent multiple pop attempts during the delay
  bool _isAttemptingPop = false;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(text: _hexValue);
    _updateColorValues(_currentColor); // Initialize all string values
    _hexController.addListener(_onHexInputChanged);
  }

  // This method updates all string representations of the color
  void _updateColorValues(Color color) {
    setState(() {
      _currentColor = color;
      _hexValue = colorToHex(
        color,
        includeHashSign: false,
      ); // Get hex without #
      // This line is from your provided code, which correctly scales and rounds RGB
      _rgbValue =
          '${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}';

      HSLColor hsl = HSLColor.fromColor(color);
      _hslValue =
          '${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%';

      // Update hex controller only if it's different to prevent feedback loop
      if (_hexController.text.toUpperCase() != _hexValue.toUpperCase()) {
        _hexController.value = _hexController.value.copyWith(text: _hexValue);
      }
      _errorMessage = null; // Clear any previous error messages
    });
  }

  // Handle direct Hex input from the TextField
  void _onHexInputChanged() {
    // Only process if the controller's text is different from the current hex value
    // to avoid unnecessary updates when _updateColorValues sets the text.
    if (_hexController.text.toUpperCase() == _hexValue.toUpperCase()) return;

    setState(() {
      _errorMessage = null;
      try {
        Color? newColor = hexToColor(_hexController.text);
        if (newColor != null) {
          _updateColorValues(newColor);
        } else {
          _errorMessage = 'Invalid Hex code. Use 6 or 8 digits (e.g., FF0000).';
        }
      } catch (e) {
        _errorMessage = 'Invalid Hex code: ${e.toString()}';
      }
    });
  }

  // Convert Hex string to Color object (utility from flutter_colorpicker)
  Color? hexToColor(String hexString) {
    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // Assume opaque if no alpha
    }
    if (hexString.length == 8) {
      try {
        return Color(int.parse(hexString, radix: 16));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Convert Color to Hex string (utility from flutter_colorpicker)
  String colorToHex(Color color, {bool includeHashSign = true}) {
    // Use toARGB32() for explicit conversion instead of deprecated .value
    String hex =
        color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return includeHashSign ? '#${hex.substring(2)}' : hex.substring(2);
  }

  // --- Copy to Clipboard ---
  void _copyToClipboard(String text, String format) {
    // This context usage is fine as it's not across an async gap
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
    _hexController.removeListener(_onHexInputChanged);
    _hexController.dispose();
    super.dispose();
  }

  // New method to handle the delayed pop
  Future<void> _handleDelayedPop() async {
    // Set flag to true immediately, before any async operation
    if (!mounted) return; // Ensure widget is mounted before setState
    setState(() {
      _isAttemptingPop = true;
    });

    // Introduce a small delay to allow graphics resources to be cleaned up
    // Increased delay to 500ms
    await Future.delayed(const Duration(milliseconds: 500));

    // Guard context usage with mounted check *immediately before* using context
    if (mounted) {
      Navigator.of(context).pop();
    }
    // No need to reset _isAttemptingPop to false as the widget will be disposed.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Replaced WillPopScope with PopScope
      canPop: false, // Prevent default pop behavior
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          // If the system already popped (e.g., due to a different navigator or gesture)
          return;
        }
        if (!_isAttemptingPop) {
          // Only trigger if not already attempting
          _handleDelayedPop(); // Call the new async method
        }
      },
      child: Scaffold(
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
                        'Color Picker',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ColorPicker(
                        key: const ValueKey(
                          'mainColorPicker',
                        ), // Key is retained
                        pickerColor: _currentColor,
                        onColorChanged: (color) {
                          _updateColorValues(
                            color,
                          ); // Update all related values
                        },
                        colorPickerWidth: 300.0,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha:
                            false, // We are only dealing with RGB/HSL without alpha
                        displayThumbColor: true,
                        labelTypes: const [
                          ColorLabelType.hex,
                          ColorLabelType.rgb,
                          ColorLabelType.hsl,
                        ],
                        paletteType:
                            PaletteType.hsv, // HSV is common for color pickers
                        pickerAreaBorderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2.0),
                          topRight: Radius.circular(2.0),
                        ),
                        hexInputBar:
                            false, // We'll handle hex input manually below
                        portraitOnly: false, // Allow landscape if needed
                      ),
                      const SizedBox(height: 24),
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
                        readOnly: false, // Allow user to type in Hex
                      ),
                      const SizedBox(height: 16),
                      // RGB Display & Copy
                      _buildColorFormatDisplay(
                        label: 'RGB',
                        value: _rgbValue,
                        formatName: 'RGB',
                      ),
                      const SizedBox(height: 16),
                      // HSL Display & Copy
                      _buildColorFormatDisplay(
                        label: 'HSL',
                        value: _hslValue,
                        formatName: 'HSL',
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
      ),
    );
  }

  // Helper widget for displaying color formats (read-only)
  Widget _buildColorFormatDisplay({
    required String label,
    required String value,
    required String formatName,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(
              text: value,
            ), // Use a new controller for display
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            readOnly: true, // Make it read-only
            keyboardType: TextInputType.text,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value, formatName),
        ),
      ],
    );
  }

  // Helper widget for Hex input (editable)
  Widget _buildColorFormatInput({
    required String label,
    required TextEditingController controller,
    required String valueToCopy,
    required String formatName,
    required TextInputType keyboardType,
    bool readOnly = true, // Default to read-only for general use
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
            readOnly: readOnly,
            // onChanged is handled by addListener in initState for hexController
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(valueToCopy, formatName),
        ),
      ],
    );
  }
}

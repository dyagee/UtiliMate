import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Ensure this import is here
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:flutter/services.dart'; // For Clipboard

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String _scanResult = 'Scan a QR code or barcode';
  bool _isTorchOn = false; // Manually manage torch state for UI

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return; // Prevent multiple scans while dialog is open

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code != null && code != _scanResult) {
      setState(() {
        _scanResult = code;
        _isScanning = false; // Pause scanning
      });
      _showScanResultDialog(code);
    }
  }

  void _showScanResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder:
          (context) => ConfirmationDialog(
            title: 'Scan Result',
            message: result,
            onConfirm: () {
              Clipboard.setData(ClipboardData(text: result));
              _showSnackBar('Result copied to clipboard!');
              _resumeScanning();
            },
            confirmButtonText: 'Copy Result',
            showCancelButton: true,
            cancelButtonText: 'Scan Again',
            onCancel: () {
              _resumeScanning();
            },
          ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _isScanning = true;
      _scanResult = 'Scan a QR code or barcode';
    });
    // Ensure camera is started/resumed if it was paused
    cameraController.start();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // New method to toggle torch and update local state
  Future<void> _toggleTorchAndState() async {
    // mobile_scanner v7's toggleTorch directly changes the state
    await cameraController.toggleTorch();
    // We update our local UI state based on the expected outcome
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'QR & Barcode Scanner',
        helpContentKey: 'QR_SCANNER',
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _handleBarcode,
                  // The 'overlay' parameter is not available in mobile_scanner v7.0.1.
                  // We use a custom Container in the Stack for visual overlay.
                ),
                // Custom overlay for visual border
                Container(
                  decoration: BoxDecoration(
                    // Corrected: Use Color.fromRGBO to avoid withOpacity deprecation
                    border: Border.all(
                      color: Color.fromRGBO(
                        255,
                        255,
                        255,
                        (0.5 * 255).round() as double,
                      ),
                      width: 2.0,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    // Corrected: Use Color.fromRGBO to avoid withOpacity deprecation
                    color: Color.fromRGBO(
                      0,
                      0,
                      0,
                      (0.6 * 255).round() as double,
                    ),
                    child: Text(
                      _scanResult,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                    child: IconButton(
                      color: Colors.white,
                      // Removed ValueListenableBuilder as torchState is not a ValueListenable in v7.
                      // Using local state _isTorchOn to control the icon.
                      icon: Icon(
                        _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: _isTorchOn ? Colors.yellow : Colors.grey,
                      ),
                      iconSize: 32.0,
                      onPressed: _toggleTorchAndState, // Call our new method
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

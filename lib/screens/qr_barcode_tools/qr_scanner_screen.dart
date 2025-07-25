// lib/screens/qr_barcode_tools/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false, // Start with torch off by default
  );
  bool _isScanning = true;
  String _scanResult = 'Scan a QR code or barcode';
  bool _isTorchOn = false; // Manually manage torch state
  bool _permissionGranted = false;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        if (status.isGranted) {
          _permissionGranted = true;
          _permissionError = null;
          // Camera starts automatically when MobileScanner widget is built and permission is granted
        } else {
          _permissionGranted = false;
          _permissionError =
              'Camera permission denied. Please enable it in settings.';
          if (status.isPermanentlyDenied) {
            _permissionError =
                'Camera permission permanently denied. Please go to app settings to enable it.';
          }
        }
      });
    }
  }

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
      cameraController
          .stop(); // Explicitly stop the camera when a result is found
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
              Navigator.of(context).pop(); // Close dialog
              _resumeScanning();
            },
            confirmButtonText: 'Copy Result',
            showCancelButton: true,
            cancelButtonText: 'Scan Again',
            onCancel: () {
              Navigator.of(context).pop(); // Close dialog
              _resumeScanning();
            },
          ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _isScanning = true;
      _scanResult = 'Scan a QR code or barcode';
      _isTorchOn = false; // Reset torch state when resuming scan
    });
    cameraController.start(); // Resume the camera
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Manually toggle torch and update local state
  Future<void> _toggleTorch() async {
    await cameraController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn; // Update local state after toggle
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'QR & Barcode Scanner',
        helpContentKey: 'QR_SCANNER_TOOL', // Updated help key
        actions: [
          // Flashlight button
          if (_permissionGranted) // Only show flashlight if camera permission is granted
            IconButton(
              color: Colors.white,
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: _isTorchOn ? Colors.yellow : Colors.grey,
              ),
              iconSize: 32.0,
              onPressed: _toggleTorch, // Call our manual toggle method
            ),
        ],
      ),
      body:
          _permissionError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FIX: Replaced Icons.camera_alt_off with Icons.no_photography
                      Icon(
                        Icons.no_photography,
                        size: 80,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _permissionError!,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        // Using ElevatedButton.icon for better visibility
                        onPressed: () => openAppSettings(), // Open app settings
                        icon: const Icon(Icons.settings),
                        label: const Text('Open App Settings'),
                      ),
                    ],
                  ),
                ),
              )
              : !_permissionGranted
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading while requesting permission
              : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: cameraController,
                          onDetect: _handleBarcode,
                          // FIX: Simplified errorBuilder signature and used error.toString()
                          errorBuilder: (
                            BuildContext context,
                            MobileScannerException error,
                          ) {
                            return Center(
                              child: Text(
                                'Error initializing camera: ${error.toString()}', // FIX: Use error.toString()
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          },
                        ),
                        // Custom overlay for visual border
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.5, // Alpha as double
                              ),
                              width: 2.0,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            color: const Color.fromRGBO(
                              0,
                              0,
                              0,
                              0.6, // Alpha as double
                            ),
                            child: Text(
                              _scanResult,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
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

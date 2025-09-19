import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/confirmation_dialog.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utilimate/services/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
  );
  bool _isScanning = true;
  String _scanResult = 'Scan a QR code or barcode';
  bool _isTorchOn = false;
  bool _permissionGranted = false;
  String? _permissionError;
  AdWidget? _bannerAdWidget;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();

    // Get the banner ad widget from the AdManager.
    _bannerAdWidget = AdManager().getBannerAdWidget();

    // The AdManager handles the asynchronous ad loading. We use setState
    // here to force a rebuild if the ad loads after the widget is first built.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _bannerAdWidget = AdManager().getBannerAdWidget();
        });
      }
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        if (status.isGranted) {
          _permissionGranted = true;
          _permissionError = null;
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
    if (!_isScanning) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code != null && code != _scanResult) {
      setState(() {
        _scanResult = code;
        _isScanning = false;
      });
      cameraController.stop();
      _showScanResultDialog(code);
    }
  }

  void _showScanResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => ConfirmationDialog(
            title: 'Scan Result',
            message: result,
            onConfirm: () {
              Clipboard.setData(ClipboardData(text: result));
              _showSnackBar('Result copied to clipboard!');
              Navigator.of(context).pop();
              AdManager().loadInterstitialAd();
              _resumeScanning();
            },
            confirmButtonText: 'Copy Result',
            showCancelButton: true,
            cancelButtonText: 'Scan Again',
            onCancel: () {
              Navigator.of(context).pop();
              AdManager().loadInterstitialAd();
              _resumeScanning();
            },
          ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _isScanning = true;
      _scanResult = 'Scan a QR code or barcode';
      _isTorchOn = false;
    });
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

  Future<void> _toggleTorch() async {
    await cameraController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the banner ad is ready to be displayed
    final bool isBannerAdReady = _bannerAdWidget != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'QR & Barcode Scanner',
        helpContentKey: 'QR_SCANNER_TOOL',
        actions: [
          if (_permissionGranted)
            IconButton(
              color: Colors.white,
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: _isTorchOn ? Colors.yellow : Colors.grey,
              ),
              iconSize: 32.0,
              onPressed: _toggleTorch,
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
                        onPressed: () => openAppSettings(),
                        icon: const Icon(Icons.settings),
                        label: const Text('Open App Settings'),
                      ),
                    ],
                  ),
                ),
              )
              : !_permissionGranted
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: _handleBarcode,
                    errorBuilder: (
                      BuildContext context,
                      MobileScannerException error,
                    ) {
                      return Center(
                        child: Text(
                          'Error initializing camera: ${error.toString()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.5),
                        width: 2.0,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: const Color.fromRGBO(0, 0, 0, 0.6),
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

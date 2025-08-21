// lib/screens/web_view_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:android_path_provider/android_path_provider.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final String helpContentKey;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    required this.helpContentKey,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  String _downloadFileName = '';

  static const String _utilimateFileSuffix = '_utilimate';

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  _snackBarController;

  static const MethodChannel _channel = MethodChannel(
    'com.example.utilimate/media_scanner',
  );

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterDownloadChannel',
            onMessageReceived: (JavaScriptMessage message) {
              developer.log('JS Channel Message: ${message.message}');
              try {
                final Map<String, dynamic> data = jsonDecode(message.message);
                final String url = data['url'];
                final String suggestedName =
                    data['suggestedName'] ?? 'download';
                _startInternalDownload(url, suggestedName);
              } catch (e) {
                developer.log(
                  'Error decoding JS message: $e, Message: ${message.message}',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error processing download link: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _isLoading = progress < 100;
                  });
                }
              },
              onPageStarted: (String url) {
                developer.log('WebView: Page started loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                developer.log('WebView: Page finished loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                _injectJavaScript();
              },
              onWebResourceError: (WebResourceError error) {
                developer.log(
                  'WebView: Web resource error: ${error.description}, URL: ${error.url}',
                );
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) async {
                developer.log('WebView: Navigation request: ${request.url}');
                final uri = Uri.parse(request.url);

                if (!request.isMainFrame ||
                    !uri.host.contains(Uri.parse(widget.url).host)) {
                  developer.log(
                    'WebView: Detected non-main frame or external host navigation: ${request.url}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationDecision.prevent;
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Disclaimer: This online tool is provided by a third-party website. UtiliMate does not control its content or data handling.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueGrey,
            duration: const Duration(days: 365),
            showCloseIcon: true,
            closeIconColor: Colors.white,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    developer.log(
      'WebView: Disposing WebViewScreen, attempting to close SnackBar.',
    );
    _snackBarController?.close();
    super.dispose();
  }

  void _injectJavaScript() {
    _controller.runJavaScript('''
      function getSuggestedFileName(url) {
          if (!url) return 'download';
          var path = url.split('/').pop().split('?')[0];
          if (path.length > 50) {
              path = path.substring(0, 50) + '...';
          }
          return decodeURIComponent(path.replace(/[^a-zA-Z0-9.\\-_]/g, '_'));
      }

      var originalWindowOpen = window.open;
      window.open = function(url, name, features) {
          if (url && url.startsWith('http')) {
              var suggestedName = getSuggestedFileName(url);
              FlutterDownloadChannel.postMessage(JSON.stringify({url: url, suggestedName: suggestedName}));
              return null;
          }
          return originalWindowOpen(url, name, features);
      };

      function isDownloadUrl(url) {
          if (!url) return false;
          var path = url.toLowerCase();
          return path.endsWith('.mp4') ||
                         path.endsWith('.mov') ||
                         path.endsWith('.avi') ||
                         path.endsWith('.mkv') ||
                         path.endsWith('.webm') ||
                         path.endsWith('.mp3') ||
                         path.endsWith('.wav') ||
                         path.endsWith('.zip') ||
                         path.endsWith('.rar') ||
                         path.endsWith('.pdf') ||
                         path.endsWith('.doc') || path.endsWith('.docx') ||
                         path.endsWith('.xls') || path.endsWith('.xlsx') ||
                         path.endsWith('.ppt') || path.endsWith('.pptx');
      }

      document.addEventListener('click', function(event) {
          var target = event.target;
          while (target && target.tagName !== 'A') {
              target = target.parentNode;
          }

          if (target && target.tagName === 'A') {
              var href = target.href;
              if (isDownloadUrl(href) || (href && !href.startsWith(window.location.origin))) {
                  var suggestedName = target.innerText.trim();
                  if (!suggestedName) {
                      suggestedName = getSuggestedFileName(this.href);
                  }
                  FlutterDownloadChannel.postMessage(JSON.stringify({url: href, suggestedName: suggestedName}));
                  event.preventDefault();
                  event.stopPropagation();
              }
          }
      }, true);

      setTimeout(function() {
          var downloadLinks = document.querySelectorAll('a[download], a[href*=".mp4"], a[href*=".mov"], a[href*=".pdf"], a[href*=".zip"]');
          downloadLinks.forEach(function(link) {
              if (link.offsetParent !== null && link.href && link.href.startsWith('http')) {
                  link.addEventListener('click', function(e) {
                      e.preventDefault();
                      var suggestedName = link.innerText.trim();
                      if (!suggestedName) {
                          suggestedName = getSuggestedFileName(this.href);
                      }
                      FlutterDownloadChannel.postMessage(JSON.stringify({url: this.href, suggestedName: suggestedName}));
                  });
              }
          });
      }, 2000);

      // Function to hide specified classes
      function hideElements() {
          var classesToHide = [
              '.header',
              '.main-form_watch_show',
              '.main-form_watch',
              '.link-plus',
              '.norton',
              '.wrapper.wrapper-after-output',
              '.other',
              '.smart-app-br.dh-top-banner',
              '.f-nav-box-column.f-nav-container',
              '.sf-apk-pro.extra' // This is the class we need to persistently hide
          ];

          classesToHide.forEach(function(className) {
              var elements = document.querySelectorAll(className);
              elements.forEach(function(element) {
                  if (element) {
                      element.style.display = 'none';
                      // console.log('Hidden element with class: ' + className); // Uncomment for debugging
                  }
              });
          });
      }

      // Run hideElements initially
      hideElements();

      // Set up a MutationObserver to watch for changes in the DOM
      var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
              // If nodes were added, check if they match our classes and hide them
              if (mutation.addedNodes.length > 0) {
                  hideElements(); // Re-run hide logic for new elements
              }
          });
      });

      // Start observing the entire document body for subtree modifications
      observer.observe(document.body, { childList: true, subtree: true });

      // Optional: Also run hideElements after a short delay for initial rendering
      setTimeout(hideElements, 500);
    ''');
  }

  // FIX: Modified _showRenameDialog to take initialBaseName and fullSuffixAndExtension
  Future<String?> _showRenameDialog(
    String initialBaseName,
    String fullSuffixAndExtension,
  ) async {
    TextEditingController nameController = TextEditingController(
      text: initialBaseName,
    );

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
              suffixText:
                  fullSuffixAndExtension, // Display the full suffix and extension
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: const Text(
                'Confirm',
              ), // Changed from 'Download' to 'Confirm' for reusability
              onPressed: () {
                Navigator.of(dialogContext).pop(nameController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  void _startInternalDownload(String url, String suggestedName) async {
    developer.log(
      'Attempting internal download for: $url with suggested name: $suggestedName',
    );
    if (!mounted) return;

    // Split suggestedName into base and extension
    String baseName = suggestedName;
    String extension = '';
    int dotIndex = suggestedName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex > 0) {
      baseName = suggestedName.substring(0, dotIndex);
      extension = suggestedName.substring(
        dotIndex,
      ); // Includes the dot, e.g., ".pdf"
    }

    // FIX: Pass only the baseName to the dialog, and construct the full suffix text
    String fullSuffixText = '$_utilimateFileSuffix$extension';
    String? userChosenBaseNameResult = await _showRenameDialog(
      baseName,
      fullSuffixText,
    );

    if (userChosenBaseNameResult == null || userChosenBaseNameResult.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download cancelled by user.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
      developer.log('WebView: Download cancelled by user.');
      return;
    }

    String userChosenBaseName = userChosenBaseNameResult;

    // FIX: Construct the final download filename by adding the suffix and extension
    String finalDownloadFileName =
        '$userChosenBaseName$_utilimateFileSuffix$extension';

    _downloadFileName = finalDownloadFileName;

    setState(() {
      _downloadProgress = 0.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing to download: $_downloadFileName'),
          backgroundColor: Colors.blueAccent,
        ),
      );
    });

    String currentFilePath;

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download failed: Storage permission denied.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        developer.log(
          'WebView: Storage permission denied for internal download.',
        );
        return;
      }

      Directory? publicDownloadsDirectory;
      if (Platform.isAndroid) {
        publicDownloadsDirectory = Directory(
          await AndroidPathProvider.downloadsPath,
        );
        developer.log(
          'Android Public Downloads Dir: ${publicDownloadsDirectory.path}',
        );
      } else if (Platform.isIOS) {
        publicDownloadsDirectory = await getApplicationDocumentsDirectory();
        developer.log('iOS Documents Dir: ${publicDownloadsDirectory.path}');
      }

      if (publicDownloadsDirectory == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Download failed: Could not find a suitable download directory.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        developer.log(
          'WebView: Could not find a suitable download directory for internal download.',
        );
        return;
      }

      if (!await publicDownloadsDirectory.exists()) {
        await publicDownloadsDirectory.create(recursive: true);
      }

      currentFilePath = '${publicDownloadsDirectory.path}/$_downloadFileName';

      int counter = 1;
      String baseNameForDuplicateCheck =
          userChosenBaseName; // Use the base name from user input

      // Ensure the suffix is removed from baseNameForDuplicateCheck if it was accidentally added by user
      if (baseNameForDuplicateCheck.endsWith(_utilimateFileSuffix)) {
        baseNameForDuplicateCheck = baseNameForDuplicateCheck.substring(
          0,
          baseNameForDuplicateCheck.length - _utilimateFileSuffix.length,
        );
      }

      // Loop to find a unique filename/path, updating currentFilePath directly
      while (await File(currentFilePath).exists()) {
        String tempBaseName = '$baseNameForDuplicateCheck (${counter++})';
        _downloadFileName =
            '$tempBaseName$_utilimateFileSuffix$extension'; // Re-add suffix and original extension
        currentFilePath = '${publicDownloadsDirectory.path}/$_downloadFileName';
      }

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Download failed: Server responded with status ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        developer.log(
          'WebView: HTTP download failed with status: ${response.statusCode}',
        );
        return;
      }

      final int? contentLength = response.contentLength;
      List<int> bytes = [];
      int downloadedBytes = 0;

      response.stream.listen(
        (List<int> newBytes) {
          bytes.addAll(newBytes);
          downloadedBytes += newBytes.length;
          if (contentLength != null && mounted) {
            setState(() {
              _downloadProgress = downloadedBytes / contentLength;
            });
          }
        },
        onDone: () async {
          await File(currentFilePath).writeAsBytes(bytes);
          if (mounted) {
            setState(() {
              _downloadProgress = 1.0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully downloaded: $_downloadFileName'),
                backgroundColor: Colors.green,
              ),
            );

            if (Platform.isAndroid) {
              try {
                await _channel.invokeMethod('scanFile', {
                  'path': currentFilePath,
                });
                developer.log(
                  'WebView: Triggered media scan for: $currentFilePath',
                );
              } on PlatformException catch (e) {
                developer.log(
                  'WebView: Failed to trigger media scan: ${e.message}',
                );
              }
            }
          }
          developer.log(
            'WebView: Successfully downloaded: $_downloadFileName to $currentFilePath',
          );
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          developer.log('WebView: Download stream error: $e');
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected download error occurred: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      developer.log('WebView: Unexpected download error: $e');
    } finally {
      setState(() {
        _downloadProgress = 0.0;
        _downloadFileName = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        helpContentKey: widget.helpContentKey,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_downloadProgress > 0 && _downloadProgress < 1.0)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
              ),
            ),
          if (_downloadProgress > 0 && _downloadProgress < 1.0)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Downloading: $_downloadFileName (${(_downloadProgress * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

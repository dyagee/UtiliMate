// lib/screens/web_view_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Still imported for general external links
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'dart:developer' as developer; // For logging
import 'package:path_provider/path_provider.dart'; // For getting download directory
import 'package:permission_handler/permission_handler.dart'; // For storage permissions
import 'dart:io'; // For Directory operations
import 'package:http/http.dart'
    as http; // For making HTTP requests to download files
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/services.dart'; // Required for MethodChannel
import 'package:android_path_provider/android_path_provider.dart'; // For public Android paths

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
  String _currentUrl = ''; // To track the current URL in the webview
  double _downloadProgress = 0.0; // To show download progress
  String _downloadFileName = ''; // To show current downloading file name

  // NEW: MethodChannel for native communication
  static const MethodChannel _channel = MethodChannel(
    'com.example.utilimate/media_scanner',
  );

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url; // Initialize with the starting URL

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          // Add a JavaScript channel to receive messages from the webview
          ..addJavaScriptChannel(
            'FlutterDownloadChannel',
            onMessageReceived: (JavaScriptMessage message) {
              developer.log('JS Channel Message: ${message.message}');
              try {
                final Map<String, dynamic> data = jsonDecode(message.message);
                final String url = data['url'];
                final String suggestedName =
                    data['suggestedName'] ?? 'download';
                _startInternalDownload(
                  url,
                  suggestedName,
                ); // Pass suggested name
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
                // Update loading status
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
                    _currentUrl =
                        url; // Update current URL when page starts loading
                  });
                }
              },
              onPageFinished: (String url) {
                developer.log('WebView: Page finished loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _currentUrl =
                        url; // Update current URL when page finishes loading
                  });
                }
                // Inject JavaScript after page finishes loading
                _injectJavaScript();
              },
              onWebResourceError: (WebResourceError error) {
                developer.log(
                  'WebView: Web resource error: ${error.description}, URL: ${error.url}',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading page: ${error.description}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) async {
                developer.log('WebView: Navigation request: ${request.url}');
                final uri = Uri.parse(request.url);

                // --- Handling for other external links (e.g., ads, social media shares, new tabs) ---
                // If the request is not for the main frame (e.g., pop-up, ad) and not from the original host
                // or if it's a new window request (target="_blank" like behavior)
                // Also, if the URL's host is different from the initial widget.url's host, launch externally.
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

                // Allow normal navigation within the WebView
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  // JavaScript injection to intercept download links and send suggested name
  void _injectJavaScript() {
    _controller.runJavaScript('''
      // Function to get a suggested filename from the URL
      function getSuggestedFileName(url) {
          if (!url) return 'download';
          var path = url.split('/').pop().split('?')[0]; // Get last part of path, remove query params
          if (path.length > 50) { // Limit length for readability
              path = path.substring(0, 50) + '...';
          }
          return decodeURIComponent(path.replace(/[^a-zA-Z0-9.\\-_]/g, '_')); // Sanitize filename
      }

      // Override window.open to send URLs to Flutter
      var originalWindowOpen = window.open;
      window.open = function(url, name, features) {
          if (url && url.startsWith('http')) { // Only intercept http/https URLs
              var suggestedName = getSuggestedFileName(url);
              FlutterDownloadChannel.postMessage(JSON.stringify({url: url, suggestedName: suggestedName}));
              return null; // Prevent the default window.open behavior
          }
          return originalWindowOpen(url, name, features);
      };

      // Function to check if a URL looks like a download
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

      // Intercept clicks on anchor tags
      document.addEventListener('click', function(event) {
          var target = event.target;
          // Traverse up the DOM to find an anchor tag
          while (target && target.tagName !== 'A') {
              target = target.parentNode;
          }

          if (target && target.tagName === 'A') {
              var href = target.href;
              // Check if it's a download link or an external link
              if (isDownloadUrl(href) || (href && !href.startsWith(window.location.origin))) {
                  var suggestedName = target.innerText.trim(); // Try inner text first
                  if (!suggestedName) {
                      suggestedName = getSuggestedFileName(this.href);
                  }
                  FlutterDownloadChannel.postMessage(JSON.stringify({url: href, suggestedName: suggestedName}));
                  event.preventDefault(); // Prevent default navigation
                  event.stopPropagation(); // Stop propagation
              }
          }
      }, true); // Use capture phase to ensure our listener runs first

      // --- Specific for savefrom.net or similar sites that give direct links ---
      // This part tries to find direct download links on the page.
      // It's a heuristic and might need adjustment for other websites.
      // For savefrom.net, the download buttons usually have a specific structure.
      // We'll look for common download link patterns.
      setTimeout(function() { // Give page some time to render dynamic content
          var downloadLinks = document.querySelectorAll('a[download], a[href*=".mp4"], a[href*=".mov"], a[href*=".pdf"], a[href*=".zip"]');
          downloadLinks.forEach(function(link) {
              // Check if the link is visible and looks like a primary download button
              if (link.offsetParent !== null && link.href && link.href.startsWith('http')) {
                  // Add a click listener to the link to send its URL to Flutter
                  link.addEventListener('click', function(e) {
                      e.preventDefault(); // Prevent default browser download
                      var suggestedName = link.innerText.trim(); // Try inner text first
                      if (!suggestedName) {
                          suggestedName = getSuggestedFileName(this.href);
                      }
                      FlutterDownloadChannel.postMessage(JSON.stringify({url: this.href, suggestedName: suggestedName}));
                  });
              }
          });
      }, 2000); // Wait 2 seconds for dynamic content to load
    ''');
  }

  // Method to show rename dialog
  Future<String?> _showRenameDialog(String suggestedName) async {
    TextEditingController nameController = TextEditingController(
      text: suggestedName,
    );
    String? extension =
        suggestedName.contains('.') ? suggestedName.split('.').last : null;
    String baseName =
        extension != null
            ? suggestedName.substring(0, suggestedName.lastIndexOf('.'))
            : suggestedName;
    nameController.text = baseName; // Pre-fill with base name

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // User must choose
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
              suffixText: extension != null ? '.$extension' : '',
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
                Navigator.of(dialogContext).pop(null); // Return null on cancel
              },
            ),
            TextButton(
              child: const Text('Download'),
              onPressed: () {
                Navigator.of(dialogContext).pop(nameController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  // Method to start internal download using http package
  void _startInternalDownload(String url, String suggestedName) async {
    developer.log(
      'Attempting internal download for: $url with suggested name: $suggestedName',
    );
    if (!mounted) return;

    // Show rename dialog
    String? userChosenName = await _showRenameDialog(suggestedName);

    if (userChosenName == null || userChosenName.isEmpty) {
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

    // Extract original extension from the URL if not present in userChosenName
    String originalExtension = '';
    Uri uri = Uri.parse(url);
    if (uri.path.contains('.')) {
      originalExtension = uri.path.split('.').last.split('?').first;
    }

    // Append extension if user didn't provide one
    if (!userChosenName.contains('.') && originalExtension.isNotEmpty) {
      _downloadFileName = '$userChosenName.$originalExtension';
    } else {
      _downloadFileName = userChosenName;
    }

    setState(() {
      _downloadProgress = 0.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing to download: $_downloadFileName'),
          backgroundColor: Colors.blueAccent,
        ),
      );
    });

    String? filePath; // Declare filePath here to be accessible for media scan

    try {
      // Request storage permission (for older Android or general)
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

      // Determine download directory based on platform
      Directory? publicDownloadsDirectory;
      if (Platform.isAndroid) {
        // FIX: Corrected to getter downloadsPath as per documentation
        publicDownloadsDirectory = Directory(
          await AndroidPathProvider.downloadsPath,
        );
        developer.log(
          'Android Public Downloads Dir: ${publicDownloadsDirectory.path}',
        );
      } else if (Platform.isIOS) {
        // For iOS, app-specific documents are usually the closest to "public" for files you manage
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

      // Ensure the directory exists
      if (!await publicDownloadsDirectory.exists()) {
        await publicDownloadsDirectory.create(recursive: true);
      }

      filePath =
          '${publicDownloadsDirectory.path}/$_downloadFileName'; // Assign to declared filePath
      final File file = File(filePath);

      // Handle duplicate file names: Append a number
      int counter = 1;
      String baseFileNameWithoutExt =
          _downloadFileName.contains('.')
              ? _downloadFileName.substring(
                0,
                _downloadFileName.lastIndexOf('.'),
              )
              : _downloadFileName;
      String ext =
          _downloadFileName.contains('.')
              ? _downloadFileName.substring(_downloadFileName.lastIndexOf('.'))
              : '';

      String finalFileName = _downloadFileName;
      String finalFilePath = filePath;

      while (await File(finalFilePath).exists()) {
        finalFileName = '$baseFileNameWithoutExt (${counter++})$ext';
        finalFilePath = '${publicDownloadsDirectory.path}/$finalFileName';
      }
      _downloadFileName = finalFileName; // Update displayed name if duplicated
      filePath = finalFilePath; // Update filePath

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
          await file.writeAsBytes(bytes);
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

            // NEW: Trigger media scan for Android
            if (Platform.isAndroid && filePath != null) {
              try {
                await _channel.invokeMethod('scanFile', {'path': filePath});
                developer.log('WebView: Triggered media scan for: $filePath');
              } on PlatformException catch (e) {
                developer.log(
                  'WebView: Failed to trigger media scan: ${e.message}',
                );
              }
            }
          }
          developer.log(
            'WebView: Successfully downloaded: $_downloadFileName to $filePath',
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
        _downloadProgress = 0.0; // Reset progress bar
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
          // Download Progress Indicator
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
          // Optional: Display current URL for debugging/user info
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                _currentUrl,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

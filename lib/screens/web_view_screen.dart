// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:utilimate/widgets/custom_app_bar.dart';

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
  bool _showDisclaimer = true; // New state variable for disclaimer visibility

  // JavaScript to inject CSS rules for hiding elements immediately.
  // This CSS will be added to the <head> of the loaded page.
  // Using !important to ensure override.
  // ALL SELECTORS ARE COMBINED WITH COMMAS.
  final String _cssInjectionJs = """
    (function() {
      var style = document.createElement('style');
      style.innerHTML = `
        nav.navbar,
        div.ap_apex_ad,
        div._ap_apex_ad,
        .vjs-tech,
        #accordion_content,
        .ml-md-4.ml-0.sede_ara,
        .as_seen,
        .main_fpt,
        .for_footer_ad,
        #ADP_41163_336x280_00000001-4e3de56e-878b-4041-9f85-2fc7fad4fad3,
        #slider_wrapper,
        #uph,

        {
          display: none !important;
        }
      `;
      document.head.appendChild(style);
      console.log('UtiliMate: CSS cleanup script injected on page started.');
    })();
  """;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(
            const Color(0x00000000),
          ) // Ensure background is transparent
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
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
                print('Page started loading: $url');
                // CRITICAL: Inject CSS here, as early as possible
                _controller.runJavaScript(_cssInjectionJs);
              },
              onPageFinished: (String url) async {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                print('Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                print('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
                // if (mounted) {
                //   // Added mounted check for SnackBar
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text('Error loading page: ${error.description}'),
                //     ),
                //   );
                // }
              },
              onNavigationRequest: (NavigationRequest request) {
                final Uri uri = Uri.parse(request.url);
                const String allowedHost = 'smallseotools.com';

                if (uri.host == allowedHost ||
                    uri.host.endsWith('.$allowedHost')) {
                  return NavigationDecision.navigate;
                }
                print('Blocked navigation to external URL: ${request.url}');
                return NavigationDecision.prevent;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
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
          // Disclaimer overlay - now closable
          Visibility(
            // Use Visibility to hide/show the disclaimer
            visible: _showDisclaimer,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(
                  (0.9 * 255).round(),
                ), // Using withAlpha for deprecation fix
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  // Use Row to place text and close button
                  children: [
                    Expanded(
                      child: Text(
                        'Disclaimer: This tool is provided via an external website. UtiliMate is not responsible for its content, ads, or how it handles your files. File downloads may occur outside the app\'s direct control.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: () {
                        setState(() {
                          _showDisclaimer = false; // Hide the disclaimer
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

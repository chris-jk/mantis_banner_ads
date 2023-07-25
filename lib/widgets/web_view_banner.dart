// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const String mantisAds = '''
      <div data-mantis-zone="test_app"></div>
      <script type="text/javascript" data-cfasync="false">
        var mantis = mantis || [];
        mantis.push(['display', 'load', {
          property: '649cacb4c69fa0000fe67548'
        }]);
      </script>
      <script type="text/javascript" data-cfasync="false" 
      src="https://assets.mantisadnetwork.com/mantodea.min.js" async></script>
      ''';

class WebViewBanner extends StatefulWidget {
  const WebViewBanner({super.key});

  @override
  State<WebViewBanner> createState() => _WebViewBannerState();
}

class _WebViewBannerState extends State<WebViewBanner> {
  late final WebViewController _controller;
  String? currentUrl;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            currentUrl = url; // Store the current URL
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                  Page resource error:
                    code: ${error.errorCode}
                    description: ${error.description}
                    errorType: ${error.errorType}
                    isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            debugPrint('allowing navigation to ${request.url}');

            // Retrieve the current URL
            debugPrint('Current URL is $currentUrl');

            // Don't try to launch about:blank URLs
            if (request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }

            if (await canLaunch(request.url)) {
              await launch(
                request.url,
                forceSafariVC: false,
                forceWebView: false,
                headers: <String, String>{'my_header_key': 'my_header_value'},
              );
              return NavigationDecision
                  .prevent; // Prevent the WebView from navigating to the new URL
            } else {
              throw 'Could not launch ${request.url}';
            }
          },
        ),
      );

    controller.loadHtmlString(mantisAds);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final webViewBannerHeight = screenHeight * 0.15;

    return SizedBox(
      height: webViewBannerHeight,
      child: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}

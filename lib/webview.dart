import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facar_app/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewScreen extends StatefulWidget {
  final bool isUpdate;
  final String googlePlayLink;
  final String appStoreLink;
  final String my_web_link; // String element to be received

  const InAppWebViewScreen({
    Key? key,
    required this.isUpdate,
    required this.googlePlayLink,
    required this.appStoreLink,
    required this.my_web_link,
  }) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();

  late final InAppWebViewController webViewController;
  double progress = 0;

  // final db = FirebaseFirestore.instance.collection('data');
  late Uri myUrl = Uri.parse(widget.my_web_link);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // print(" almohsen ${widget.isUpdate} myya $googlePlayLink + $appStoreLink");
    if (widget.isUpdate) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text('تحديث التطبيق'),
              content: Text('عذرا يرجى تحديث التطبيق'),
              actions: [
                TextButton(
                  child: Text('خروج'),
                  onPressed: () {
                    // Close the current screen and exit the app
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                ),
                TextButton(
                  child: Text('تحديث'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Perform any required actions for redirecting to the store
                    // You can use the googlePlayLink and appStoreLink variables here

                    String link;
                    if (Platform.isAndroid) {
                      link = widget.googlePlayLink;
                    } else if (Platform.isIOS) {
                      link = widget.appStoreLink;
                    } else {
                      // Unsupported platform
                      return;
                    }
                    await launch(link);
                    //
                    // if (await canLaunchUrl( Uri.parse(link))) {
                    //
                    // } else {
                    //   // Failed to launch the link
                    // }
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: myUrl),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          cacheEnabled: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          javaScriptEnabled: true,
                          useOnDownloadStart: true,
                          useOnLoadResource: true,
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true,
                          verticalScrollBarEnabled: true,
                          userAgent:
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36',
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          allowContentAccess: true,
                          builtInZoomControls: true,
                          thirdPartyCookiesEnabled: true,
                          allowFileAccess: true,
                          supportMultipleWindows: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: true,
                        ),
                      ),
                      onLoadStart:
                          (InAppWebViewController controller, Uri? url) async {
                        if (url != null &&
                            url.scheme == 'whatsapp' &&
                            await canLaunchUrl(url)) {
                          await launchUrl(url);

                          /*   Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SplashScreen()),
                          );*/
                          return;
                        }
                        // Handle other URL schemes or continue loading the URL in the WebView
                        // ...
                      },
                      onLoadStop: (InAppWebViewController controller, uri) {
                        setState(() {
                          myUrl = uri!;
                        });
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT,
                        );
                      },
                      onWebViewCreated: (controller) {
                        // Save the webViewController for further use
                        webViewController = controller;
                      },
                      onCreateWindow: (controller, createWindowRequest) async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: InAppWebView(
                                  // Setting the windowId property isimportant here!
                                  windowId: createWindowRequest.windowId,
                                  initialOptions: InAppWebViewGroupOptions(
                                    android: AndroidInAppWebViewOptions(
                                      builtInZoomControls: true,
                                      thirdPartyCookiesEnabled: true,
                                      cacheMode: AndroidCacheMode
                                          .LOAD_CACHE_ELSE_NETWORK,
                                    ),
                                    crossPlatform: InAppWebViewOptions(
                                      cacheEnabled: true,
                                      javaScriptEnabled: true,
                                      userAgent:
                                          "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                                    ),
                                    ios: IOSInAppWebViewOptions(
                                      allowsInlineMediaPlayback: true,
                                      allowsBackForwardNavigationGestures: true,
                                    ),
                                  ),
                                  onCloseWindow: (controller) async {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        return true;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}

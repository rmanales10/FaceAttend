import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FaceRecognitionPage extends StatefulWidget {
  final String attendanceId;

  const FaceRecognitionPage({
    super.key,
    required this.attendanceId,
  });

  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  void _initializeWebViewController() {
    late final PlatformWebViewControllerCreationParams params;

    if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    // CRITICAL: This is the key to granting camera/microphone permissions
    _controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (WebViewPermissionRequest request) {
        request.grant();
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Inject JavaScript to detect when attendance is saved
            _controller.runJavaScript('''
              window.addEventListener('beforeunload', function() {
                // This will be called when the page tries to close
              });
              
              // Override window.close to send message to Flutter
              const originalClose = window.close;
              window.close = function() {
                window.location.href = 'flutter://attendance-saved';
              };
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Listen for our custom URL scheme
            if (request.url.startsWith('flutter://attendance-saved')) {
              // Close the webview and go back to the student list
              Navigator.of(context)
                  .pop(true); // Return true to indicate attendance was saved
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(false);

    // Additional Android-specific settings
    if (Platform.isAndroid) {
      AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _loadFaceRecognitionApp();
  }

  Future<void> _requestCameraPermission() async {
    // Request both camera and microphone permissions for webview
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted =
        statuses[Permission.camera] == PermissionStatus.granted;
    final micGranted =
        statuses[Permission.microphone] == PermissionStatus.granted;

    setState(() {
      _hasPermission = cameraGranted && micGranted;
    });

    if (_hasPermission) {
      _initializeWebViewController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Camera permission required'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadFaceRecognitionApp() async {
    // Load your Next.js face recognition app with attendance ID (PUBLIC ROUTE - NO AUTH REQUIRED)
    // Replace the URL with your actual deployed Next.js URL
    // For local development, use your local IP address
    final baseUrl =
        'https://ustp-face-attend.site'; // Update this URL as needed
    final url =
        '$baseUrl/face-recognition-public?attendanceId=${widget.attendanceId}&autostart=true';

    await _controller.loadRequest(Uri.parse(url));
  }
}

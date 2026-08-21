// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inAppWebView;
// import 'package:webview_flutter/webview_flutter.dart';

// class IFramePlayerPage extends StatefulWidget {
//   final String? url;
//   IFramePlayerPage({this.url});

//   @override
//   _IFramePlayerPageState createState() => _IFramePlayerPageState();
// }

// class _IFramePlayerPageState extends State<IFramePlayerPage> {
//   var playerResponse;
//   GlobalKey sc = new GlobalKey<ScaffoldState>();

//   late final WebViewController _webViewController;

//   @override
//   void initState() {
//     super.initState();

//     // Orientation and UI adjustments
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//     SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

//     // Create the controller
//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       );
//   }

//   @override
//   void dispose() {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print("iFrame Video URL :-> ${widget.url}");
//     // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//     // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
//     // double width;
//     // double height;
//     // width = MediaQuery.of(context).size.width;
//     // height = MediaQuery.of(context).size.height;
//     // JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//     //   return JavascriptChannel(
//     //       name: 'Toaster',
//     //       onMessageReceived: (JavascriptMessage message) {
//     //         ScaffoldMessenger.of(context).showSnackBar(
//     //           SnackBar(
//     //             content: Text(message.message),
//     //           ),
//     //         );
//     //       });
//     // }

//     final String? videoUrl = widget.url;
//     final bool isGoogleDrive =
//         videoUrl?.startsWith('https://drive.google.com') ?? false;
//     return Scaffold(
//       body: SafeArea(
//         child: SizedBox.expand(
//           child: isGoogleDrive
//               ? inAppWebView.InAppWebView(
//                   initialUrlRequest: inAppWebView.URLRequest(
//                     url: inAppWebView.WebUri(videoUrl!),
//                   ),
//                 )
//               : FutureBuilder<void>(
//                   future: _loadHtml(videoUrl!),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       return WebViewWidget(controller: _webViewController);
//                     } else {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                   },
//                 ),
//         ),
//       ),
//     );

//     // return Scaffold(
//     //   key: sc,
//     //   body: SafeArea(
//     //     child: Container(
//     //       width: width,
//     //       height: height,
//     //       child: (widget.url?.substring(0, 24) == 'https://drive.google.com')
//     //           ? inAppWebView.InAppWebView(
//     //               initialUrlRequest: inAppWebView.URLRequest(
//     //                 url: inAppWebView.WebUri.uri(Uri.tryParse(widget.url!)!),
//     //               ),
//     //             )
//     //           : WebView(
//     //               initialUrl: Uri.dataFromString(
//     //                 '''
//     //                   <html>
//     //                   <body style="width:100%;height:100%;display:block;background:black;">
//     //                   <iframe width="100%" height="100%"
//     //                   style="width:100%;height:100%;display:block;background:black;"
//     //                   src="${widget.url}"
//     //                   frameborder="0"
//     //                   allow="accelerometer; autoplay; encrypted-media; gyroscope;"
//     //                    allowfullscreen="allowfullscreen"
//     //                     mozallowfullscreen="mozallowfullscreen"
//     //                     msallowfullscreen="msallowfullscreen"
//     //                     oallowfullscreen="oallowfullscreen"
//     //                     webkitallowfullscreen="webkitallowfullscreen"
//     //                    >
//     //                   </iframe>
//     //                   </body>
//     //                   </html>
//     //                 ''',
//     //                 mimeType: 'text/html',
//     //                 encoding: Encoding.getByName('utf-8'),
//     //               ).toString(),
//     //               javascriptMode: JavascriptMode.unrestricted,
//     //               onWebViewCreated: (WebViewController webViewController) {
//     //                 _controller.complete(webViewController);
//     //               },
//     //               javascriptChannels: <JavascriptChannel>[
//     //                 _toasterJavascriptChannel(context),
//     //               ].toSet(),
//     //             ),
//     //     ),
//     //   ),
//     // );
//   }

//   Future<void> _loadHtml(String url) async {
//     final String htmlContent = '''
//       <html>
//         <body style="margin:0;padding:0;overflow:hidden;background:black;">
//           <iframe width="100%" height="100%"
//             src="$url"
//             frameborder="0"
//             allow="accelerometer; autoplay; encrypted-media; gyroscope;"
//             allowfullscreen
//             style="border:none;">
//           </iframe>
//         </body>
//       </html>
//     ''';

//     final String contentBase64 = base64Encode(utf8.encode(htmlContent));
//     await _webViewController.loadRequest(
//       Uri.parse('data:text/html;base64,$contentBase64'),
//     );
//   }
// }

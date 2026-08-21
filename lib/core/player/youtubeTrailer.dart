// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:webview_flutter/webview_flutter.dart';

// class YoutubePlayerMovieTrailer extends StatefulWidget {
//   final dynamic id;
//   final dynamic type;
//   final dynamic url;

//   const YoutubePlayerMovieTrailer({super.key, this.id, this.type, this.url});

//   @override
//   State<YoutubePlayerMovieTrailer> createState() =>
//       _YoutubePlayerMovieTrailerState();
// }

// class _YoutubePlayerMovieTrailerState extends State<YoutubePlayerMovieTrailer>
//     with WidgetsBindingObserver {
//   late final WebViewController _webViewController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

//     final videoId = convertUrlToId(widget.url);
//     final htmlContent = '''
//       <html>
//         <body style="margin:0;padding:0;background:black;">
//           <iframe width="100%" height="100%" 
//             src="https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&playsinline=1" 
//             frameborder="0" 
//             allow="accelerometer; autoplay; encrypted-media; gyroscope;" 
//             allowfullscreen>
//           </iframe>
//         </body>
//       </html>
//     ''';

//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.dataFromString(
//         htmlContent,
//         mimeType: 'text/html',
//         encoding: Encoding.getByName('utf-8'),
//       ));
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       _webViewController.reload();
//     }
//   }

//   static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
//     if (!url.contains("http") && (url.length == 11)) return url;
//     if (trimWhitespaces) url = url.trim();

//     for (var exp in [
//       RegExp(
//           r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
//       RegExp(
//           r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
//       RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
//     ]) {
//       Match? match = exp.firstMatch(url);
//       if (match != null && match.groupCount >= 1) return match.group(1);
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(
//             width: size.width,
//             height: size.height,
//             child: WebViewWidget(controller: _webViewController),
//           ),
//           Positioned(
//             top: 26.0,
//             left: 4.0,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: () {
//                 _webViewController.reload();
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '/common/apipath.dart';
// import '/common/global.dart';
// import '/models/episode.dart';
// import '/providers/user_profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PlayerMovie extends StatefulWidget {
//   final dynamic id;
//   final dynamic type;

//   const PlayerMovie({super.key, this.id, this.type});

//   @override
//   State<PlayerMovie> createState() => _PlayerMovieState();
// }

// class _PlayerMovieState extends State<PlayerMovie> with WidgetsBindingObserver {
//   late final WebViewController _webViewController;
//   late Future<void> _initFuture;
//   DateTime? currentBackPressTime;
//   bool canPop = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

//     WakelockPlus.enable();

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

//     _initFuture = _loadInitialUrl();
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

//     WakelockPlus.disable();
//     super.dispose();
//   }

//   @override
//   Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.resumed ||
//         state == AppLifecycleState.paused) {
//       _webViewController.reload();
//     }
//   }

//   Future<void> _loadInitialUrl() async {
//     final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
//         .userProfileModel;

//     final uri = widget.type == DatumType.T
//         ? Uri.parse(APIData.tvSeriesPlayer +
//             '${userDetails!.user!.id}/${userDetails.code}/$ser')
//         : Uri.parse(APIData.moviePlayer +
//             '${userDetails!.user!.id}/${userDetails.code}/${widget.id}');

//     final response = await http.get(uri);
//     if (response.statusCode == 200) {
//       await _webViewController.loadRequest(uri);
//     } else {
//       debugPrint("Failed to load video URL: ${response.statusCode}");
//     }
//   }

//   Future<bool> onWillPopS() async {
//     final now = DateTime.now();
//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       Navigator.pop(context);
//       return true;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
//         .userProfileModel;

//     final displayUrl = widget.type == DatumType.T
//         ? APIData.tvSeriesPlayer +
//             '${userDetails!.user!.id}/${userDetails.code}/$ser'
//         : APIData.moviePlayer +
//             '${userDetails!.user!.id}/${userDetails.code}/${widget.id}';

//     debugPrint("Player URL: $displayUrl");

//     return PopScope(
//       canPop: canPop,
//       onPopInvokedWithResult: (didPop, context) async {
//         canPop = await onWillPopS();
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             FutureBuilder(
//               future: _initFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return WebViewWidget(controller: _webViewController);
//                 } else {
//                   return const Center(
//                       child: CircularProgressIndicator(
//                     color: Colors.red,
//                   ));
//                 }
//               },
//             ),
//             Positioned(
//               top: 26.0,
//               left: 4.0,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios),
//                 onPressed: () async {
//                   canPop = await onWillPopS();
//                   if (canPop) Navigator.pop(context);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

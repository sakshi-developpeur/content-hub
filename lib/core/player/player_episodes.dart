// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import '/common/apipath.dart';
// import '/common/global.dart';
// import '/providers/user_profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;

// class PlayerEpisode extends StatefulWidget {
//   final dynamic id;
//   const PlayerEpisode({super.key, this.id});

//   @override
//   State<PlayerEpisode> createState() => _PlayerEpisodeState();
// }

// class _PlayerEpisodeState extends State<PlayerEpisode>
//     with WidgetsBindingObserver {
//   late final WebViewController _webViewController;
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
//       ..setJavaScriptMode(JavaScriptMode.unrestricted);
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
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.paused:
//         _webViewController.reload();
//         await screenLogout();
//         break;
//       case AppLifecycleState.resumed:
//         await updateScreens(myActiveScreen, fileContent!["screenCount"]);
//         break;
//       case AppLifecycleState.detached:
//         await screenLogout();
//         break;
//       case AppLifecycleState.hidden:
//         break;
//     }
//   }

//   Future<void> updateScreens(screen, count) async {
//     final response = await http.post(
//       Uri.parse(APIData.updateScreensApi),
//       body: {
//         "macaddress": '$ip',
//         "screen": '$screen',
//         "count": '$count',
//       },
//       headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
//     );
//     debugPrint("Update Screens: ${response.statusCode} ${response.body}");
//   }

//   Future<void> screenLogout() async {
//     await http.post(
//       Uri.parse(APIData.screenLogOutApi),
//       body: {
//         "screen": '$myActiveScreen',
//         "count": '${fileContent!['screenCount']}',
//       },
//       headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
//     );

//     final accessToken = await http.post(
//       Uri.parse(APIData.loginApi),
//       body: {
//         "email": fileContent!['user'],
//         "password": fileContent!['pass'],
//       },
//     );

//     if (accessToken.statusCode == 200) {
//       final user = json.decode(accessToken.body);
//       setState(() {
//         authToken = "${user['access_token']}";
//       });
//     }
//   }

//   Future<bool> onWillPopS() async {
//     final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
//         .userProfileModel!;
//     if (userDetails.payment != "Free") {
//       await screenLogout();
//     }

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
//         .userProfileModel!;
//     final episodeUrl = APIData.episodePlayer +
//         '${userDetails.user!.id}/${userDetails.code}/${widget.id}';

//     _webViewController.loadRequest(Uri.parse(episodeUrl));

//     return PopScope(
//       canPop: canPop,
//       onPopInvokedWithResult: (didPop, context) async {
//         canPop = await onWillPopS();
//       },
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             WebViewWidget(controller: _webViewController),
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

// class LocalLoader {
//   Future<String> loadLocal(BuildContext context) async {
//     final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
//         .userProfileModel!;
//     return await rootBundle.loadString(
//       APIData.moviePlayer + '${userDetails.user!.id}/${userDetails.code}',
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '/common/apipath.dart';
// import '/models/episode.dart';
// import '/providers/user_profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PlayerMovieTrailer extends StatefulWidget {
//   final dynamic id;
//   final dynamic type;

//   const PlayerMovieTrailer({super.key, this.id, this.type});

//   @override
//   State<PlayerMovieTrailer> createState() => _PlayerMovieTrailerState();
// }

// class _PlayerMovieTrailerState extends State<PlayerMovieTrailer>
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

//     final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
//         .userProfileModel!;
//     final trailerUrl = widget.type == DatumType.T
//         ? APIData.tvtrailerPlayer +
//             '${userDetails.user!.id}/${userDetails.code}/${widget.id}'
//         : APIData.trailerPlayer +
//             '${userDetails.user!.id}/${userDetails.code}/${widget.id}';

//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(trailerUrl));
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
//   Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       _webViewController.reload();
//     }
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

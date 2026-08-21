import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/agora_join_result_model.dart';
import '../../data/models/live_event_model.dart';
import '../../data/repositories/livestreaming_repository.dart';

class LivePlayerController extends GetxController {
  final LivestreamingRepository _repository;

  LivePlayerController(this._repository);

  late RtcEngine engine;
  
  final RxBool isJoined = false.obs;
  final RxInt remoteUid = 0.obs;
  final RxBool isEngineInitialized = false.obs;
  final RxString errorMessage = ''.obs;
  
  final RxInt viewerCount = 0.obs;

  Timer? _heartbeatTimer;
  late LiveEvent currentEvent;
  late AgoraDetails agoraDetails;

  @override
  void onInit() {
    super.onInit();
    // Allow both orientations for live player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      currentEvent = args['event'] as LiveEvent;
      agoraDetails = args['agoraData'] as AgoraDetails;
      viewerCount.value = currentEvent.viewerCount;
      _initAgora();
    } else {
      errorMessage.value = 'Missing arguments';
    }
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    if (isEngineInitialized.value) {
      engine.leaveChannel();
      engine.release();
    }
    // Restore portrait mode when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.onClose();
  }

  Future<void> _initAgora() async {
    try {
      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Create RTC Engine instance
      engine = createAgoraRtcEngine();

      // Initialize with App ID
      await engine.initialize(RtcEngineContext(
        appId: agoraDetails.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      isEngineInitialized.value = true;

      // Set up event handlers
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            isJoined.value = true;
            _startHeartbeat();
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            // For audience, we want to watch the host. Assuming the first remote user is the host.
            if (remoteUid.value == 0) {
              remoteUid.value = uid;
            }
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            if (remoteUid.value == uid) {
              remoteUid.value = 0;
            }
          },
          onError: (ErrorCodeType err, String msg) {
            errorMessage.value = 'Agora Error: $msg';
          },
        ),
      );

      // Set client role to Audience
      await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      
      // Enable video
      await engine.enableVideo();

      // Join channel
      await engine.joinChannel(
        token: agoraDetails.token,
        channelId: agoraDetails.channelName,
        uid: agoraDetails.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      errorMessage.value = 'Failed to initialize Agora: $e';
    }
  }

  void _startHeartbeat() {
    // Send immediate heartbeat
    _sendHeartbeat();
    
    // Set up timer for every 30 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
  }

  Future<void> _sendHeartbeat() async {
    final result = await _repository.sendHeartbeat(currentEvent.id);
    if (result.isSuccess) {
      viewerCount.value = result.data ?? viewerCount.value;
    }
  }

  void leaveStream() {
    Get.back();
  }

  void toggleOrientation() {
    if (Get.context != null) {
      final isPortrait = MediaQuery.of(Get.context!).orientation == Orientation.portrait;
      if (isPortrait) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    }
  }
}

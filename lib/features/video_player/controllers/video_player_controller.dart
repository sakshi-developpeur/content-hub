import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/home/data/models/audio_track_model.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';

import 'package:estoriz/core/routes/app_routes.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

enum PlayerDisplayMode { full, mini, hidden }

class OttVideoPlayerController extends GetxController
    with WidgetsBindingObserver {
  static final Rxn<OttVideoPlayerController> activeController =
      Rxn<OttVideoPlayerController>();

  static const String _fallbackMediaOrigin = 'http://13.203.145.200:8004';
  static const String _fallbackApiOrigin = 'http://13.203.145.200:8004/api/';

  BetterPlayerController? betterPlayerController;
  final GlobalKey betterPlayerKey = GlobalKey();

  final isPlaying = false.obs;
  final isInitialized = false.obs;
  final isBuffering = false.obs;
  final isFullScreen = false.obs;
  final isInPip = false.obs;
  final playerMode = PlayerDisplayMode.hidden.obs;
  final isLocked = false.obs;
  final isPinching = false.obs;
  final showControls = true.obs;
  final isInitializing = false.obs;
  final videoTitle = ''.obs;
  bool isViewAttached = false;

  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;

  // Gestures
  final volume = 1.0.obs;
  final brightness = 1.0.obs;
  final showVolumeIndicator = false.obs;
  final showBrightnessIndicator = false.obs;

  // Zoom / Fill mode
  final videoFit = BoxFit.contain.obs;
  final showFitModeLabel = false.obs;
  bool get isFillMode => videoFit.value == BoxFit.cover;

  // Subtitles
  final hlsSubtitles = <BetterPlayerAsmsTrack>[].obs;
  final currentSubtitle = Rxn<BetterPlayerAsmsTrack>();

  // Next Episode
  final hasNextEpisode = false.obs;
  final nextEpisodeTitle = ''.obs;
  final showNextEpisodeCountdown = false.obs;
  final nextEpisodeTimerSeconds = 10.obs;

  // double-tap ripple feedback
  final doubleTapLeft = false.obs;
  final doubleTapRight = false.obs;

  // Audio track state
  final RxList<BetterPlayerAsmsAudioTrack> hlsAudioTracks =
      <BetterPlayerAsmsAudioTrack>[].obs;
  final Rx<BetterPlayerAsmsAudioTrack?> currentAudioTrack =
      Rx<BetterPlayerAsmsAudioTrack?>(null);

  /// Pre-loaded audio track metadata from the API (before HLS parsing).
  final RxList<AudioTrackModel> apiAudioTracks = <AudioTrackModel>[].obs;

  Timer? _hideTimer;
  Timer? _positionTimer;
  String? _currentUrl;
  final UserData _userData = UserData();
  final WatchHistoryRepository _watchHistoryRepository =
      WatchHistoryRepository();
  String _videoId = '';
  String _videoTitle = 'Untitled';
  String _videoThumbnail = '';
  int _lastTrackedTenSecondMark = -1;
  bool _completionSent = false;

  // ─── Title ──────────────────────────────────────────────────────────

  void updateTitle(String title) {
    videoTitle.value = title;
  }

  // ─── Initialise ─────────────────────────────────────────────────────

  Future<void> initVideo(
    String url, {
    bool autoPlay = true,
    String? videoId,
    String? title,
    String? thumbnail,
    int startPositionSeconds = 0,
    List<AudioTrackModel>? audioTracks,
  }) async {
    final resolvedUrl = _resolveUrl(url);
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      debugPrint('OttVideoPlayerController error: invalid video URL -> "$url"');
      return;
    }

    if (_currentUrl == resolvedUrl && isInitialized.value) return;

    isInitializing.value = true;
    isInitialized.value = false;
    isPlaying.value = false;
    currentPosition.value = Duration.zero;
    totalDuration.value = Duration.zero;
    hlsAudioTracks.clear();
    currentAudioTrack.value = null;

    if (audioTracks != null) {
      apiAudioTracks.assignAll(audioTracks);
    }

    try {
      // Dispose previous controller
      betterPlayerController?.dispose();
      betterPlayerController = null;

      final headers = _buildVideoHeaders();

      // Configure data source for HLS
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        resolvedUrl,
        headers: headers,
        useAsmsAudioTracks: true,
        useAsmsTracks: true,
      );

      // Smart Resume logic: Restart from 0 if position is invalid or near the end.
      Duration? startAt;
      if (startPositionSeconds > 0) {
        startAt = Duration(seconds: startPositionSeconds);
      }

      // Player configuration — we hide built-in controls (custom overlay)
      final configuration = BetterPlayerConfiguration(
        autoPlay: autoPlay,
        looping: false,
        fit: BoxFit.contain,
        startAt: startAt,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
          enablePip: true,
        ),
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: false,
        handleLifecycle: false,
        autoDispose: false,
      );

      final controller = BetterPlayerController(
        configuration,
        betterPlayerDataSource: dataSource,
      );

      // Enable wakelock when video starts initializing
      WakelockPlus.enable();

      // Listen to events
      controller.addEventsListener(_onBetterPlayerEvent);

      betterPlayerController = controller;
      _currentUrl = resolvedUrl;

      if (videoId != null && videoId.trim().isNotEmpty) {
        _videoId = videoId.trim();
      }
      if (title != null && title.trim().isNotEmpty) {
        _videoTitle = title.trim();
      }
      if (thumbnail != null && thumbnail.trim().isNotEmpty) {
        _videoThumbnail = thumbnail.trim();
      }

      _resetTrackingState();
      _startPositionTimer();
      _startHideTimer();
    } catch (e) {
      debugPrint('OttVideoPlayerController error: $e');
      isInitializing.value = false;
    }
  }

  // ─── BetterPlayer event handler ─────────────────────────────────────

  void _onBetterPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _onInitialized();
        break;
      case BetterPlayerEventType.play:
        isPlaying.value = true;
        WakelockPlus.enable();
        break;
      case BetterPlayerEventType.pause:
        isPlaying.value = false;
        WakelockPlus.disable();
        break;
      case BetterPlayerEventType.bufferingStart:
        isBuffering.value = true;
        break;
      case BetterPlayerEventType.bufferingEnd:
        isBuffering.value = false;
        break;
      case BetterPlayerEventType.finished:
        isPlaying.value = false;
        if (!_completionSent) {
          _completionSent = true;
          _trackWatchEvent(completed: true, force: true);
        }
        break;
      case BetterPlayerEventType.progress:
        _updatePosition();
        break;
      case BetterPlayerEventType.pipStart:
        isInPip.value = true;
        debugPrint('OttVideoPlayerController: System PiP Started');
        break;
      case BetterPlayerEventType.pipStop:
        isInPip.value = false;
        debugPrint('OttVideoPlayerController: System PiP Stopped');
        break;
      default:
        break;
    }
  }

  static const _pipChannel = MethodChannel('com.estoriz/pip');

  @override
  void onInit() {
    super.onInit();
    // Use post-frame callback to avoid "setState() during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If there's another controller active (e.g. in mini mode), close it first
      if (activeController.value != null && activeController.value != this) {
        activeController.value?.closePlayer();
      }
      activeController.value = this;
    });
    WidgetsBinding.instance.addObserver(this);
    _initBrightness();
    // Enable auto-PiP on the native Android side
    if (Platform.isAndroid) {
      try {
        _pipChannel.invokeMethod('enable_auto_pip');
      } catch (e) {
        debugPrint(
          'OttVideoPlayerController: Failed to enable Android PiP: $e',
        );
      }
    }
    // Listen for PiP mode changes from the native Android side
    _pipChannel.setMethodCallHandler((call) async {
      if (call.method == 'pip_started') {
        isInPip.value = true;
        debugPrint('OttVideoPlayerController: Native PiP Started');

        // Ensure video keeps playing when entering PiP, just in case
        // lifecycle events tried to pause it.
        betterPlayerController?.play();

        if (isFullScreen.value) {
          // If we were in landscape, switch to portrait while entering PiP.
          // This prevents the jarring landscape->portrait flash when the user
          // taps the PiP window to restore the app.
          exitFullScreen();
        }
      } else if (call.method == 'pip_stopped') {
        isInPip.value = false;
        debugPrint('OttVideoPlayerController: Native PiP Stopped');
      } else if (call.method == 'pip_closed') {
        debugPrint('OttVideoPlayerController: PiP fully closed');
        isInPip.value = false;

        // Stop playback and clean up
        await stopVideo();
        playerMode.value = PlayerDisplayMode.hidden;
        await closePlayer();
      }
    });
  }

  Future<void> _initBrightness() async {
    try {
      final b = await ScreenBrightness().current;
      brightness.value = b;
    } catch (e) {
      debugPrint('ScreenBrightness not initialized: $e');
      // If plugin fails, we still allow the UI to show the indicator
      // but actual system brightness won't change until a full restart.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("Lifecycle: $state");

    if (state == AppLifecycleState.resumed) {
      debugPrint("APP RESUMED");

      // restore player UI after PiP closed
      if (betterPlayerController != null) {
        playerMode.value = PlayerDisplayMode.full;

        Future.delayed(const Duration(milliseconds: 300), () async {
          try {
            await betterPlayerController?.play();
          } catch (e) {
            debugPrint("Resume playback error: $e");
          }
        });
      }
    }

    if (state == AppLifecycleState.paused) {
      if (!isInPip.value) {
        betterPlayerController?.pause();
      }
    }
  }

  void _onInitialized() {
    final controller = betterPlayerController;
    if (controller == null) return;

    final duration = controller.videoPlayerController?.value.duration;
    if (duration != null) {
      totalDuration.value = duration;

      // Smart Restart: If we resumed near the end (last 5s), restart from 0.
      final watched =
          controller.videoPlayerController?.value.position ?? Duration.zero;
      if (duration.inSeconds > 0 &&
          watched.inSeconds >= duration.inSeconds - 5) {
        debugPrint(
          'OttVideoPlayerController: Resumed near end, restarting from 0',
        );
        seekTo(Duration.zero);
      }
    }

    isInitialized.value = true;
    isInitializing.value = false;
    isPlaying.value =
        controller.videoPlayerController?.value.isPlaying ?? false;

    // Populate HLS audio and subtitle tracks after initialization
    _loadHlsAudioTracks();
    _loadHlsSubtitleTracks();

    _trackWatchEvent(completed: false, force: true);
  }

  void _loadHlsSubtitleTracks() {
    final tracks = betterPlayerController?.betterPlayerAsmsTracks;
    if (tracks != null) {
      // Filter for subtitles only
      final subtitles = tracks
          .where(
            (t) =>
                (t.mimeType?.contains('vtt') ?? false) ||
                (t.mimeType?.contains('srt') ?? false),
          )
          .toList();
      hlsSubtitles.assignAll(subtitles);
    }
  }

  /// Loads HLS audio tracks from the stream manifest.
  void _loadHlsAudioTracks() {
    final tracks = betterPlayerController?.betterPlayerAsmsAudioTracks;
    if (tracks != null && tracks.isNotEmpty) {
      hlsAudioTracks.assignAll(tracks);
      debugPrint(
        'OttVideoPlayerController: Found ${tracks.length} HLS audio tracks',
      );
    }
  }

  // ─── Audio Track Switching ──────────────────────────────────────────

  /// Sets the audio track on the HLS stream.
  void setAudioTrack(BetterPlayerAsmsAudioTrack track) {
    betterPlayerController?.setAudioTrack(track);
    currentAudioTrack.value = track;
    debugPrint(
      'OttVideoPlayerController: Switched audio to ${track.label ?? track.language}',
    );
  }

  /// Finds an HLS audio track matching the given language code (e.g. "hi").
  BetterPlayerAsmsAudioTrack? findTrackByLanguageCode(String languageCode) {
    final code = languageCode.toLowerCase().trim();
    if (code.isEmpty) return null;
    return hlsAudioTracks.firstWhereOrNull(
      (track) => (track.language?.toLowerCase() ?? '') == code,
    );
  }

  /// Finds an HLS audio track matching a display name (e.g. "Hindi").
  BetterPlayerAsmsAudioTrack? findTrackByLabel(String label) {
    final target = label.toLowerCase().trim();
    if (target.isEmpty) return null;
    return hlsAudioTracks.firstWhereOrNull(
      (track) => (track.label?.toLowerCase() ?? '') == target,
    );
  }

  // ─── URL resolution ─────────────────────────────────────────────────

  String? _resolveUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    // Already a valid absolute URL
    final direct = Uri.tryParse(value);
    if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
      return value;
    }

    // Protocol-relative
    if (value.startsWith('//')) return 'https:$value';

    // Relative path
    if (value.startsWith('/')) return '$_fallbackMediaOrigin$value';
    return '$_fallbackApiOrigin$value';
  }

  void _resetTrackingState() {
    _lastTrackedTenSecondMark = -1;
    _completionSent = false;
  }

  Map<String, String> _buildVideoHeaders() {
    final headers = <String, String>{
      'User-Agent': 'OttApp/1.0 (Flutter Video Player)',
      'Accept': '*/*',
      'Connection': 'keep-alive',
    };

    final token = _userData.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ─── Position tracking ──────────────────────────────────────────────

  void _updatePosition() {
    final pos = betterPlayerController?.videoPlayerController?.value.position;
    if (pos != null) {
      currentPosition.value = pos;
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updatePosition();

      final pos = currentPosition.value;
      if (_videoId.isEmpty) return;

      final currentSeconds = pos.inSeconds;
      final currentMark = currentSeconds ~/ 10;
      if (currentSeconds > 0 && currentMark > _lastTrackedTenSecondMark) {
        _lastTrackedTenSecondMark = currentMark;
        _trackWatchEvent(completed: false);
      }
    });
  }

  Future<void> _trackWatchEvent({
    required bool completed,
    bool force = false,
  }) async {
    if (_videoId.isEmpty) return;

    final duration = totalDuration.value.inSeconds;
    final watched = currentPosition.value.inSeconds;

    await _watchHistoryRepository.addOrUpdateHistory(
      WatchHistoryModel(
        videoId: _videoId,
        title: _videoTitle,
        thumbnail: _videoThumbnail,
        videoUrl: _currentUrl ?? '',
        totalDuration: duration,
        watchedPosition: completed && duration > 0 ? duration : watched,
        lastWatched: DateTime.now(),
      ),
    );
  }

  // ─── Playback controls ─────────────────────────────────────────────

  void togglePlayPause() {
    if (betterPlayerController == null || !isInitialized.value) return;
    if (isPlaying.value) {
      betterPlayerController!.pause();
    } else {
      betterPlayerController!.play();
    }
    _resetHideTimer();
  }

  void seekForward() {
    _seek(const Duration(seconds: 10));
    _showDoubleTapFeedback(right: true);
    _resetHideTimer();
  }

  void seekBackward() {
    _seek(const Duration(seconds: -10));
    _showDoubleTapFeedback(left: true);
    _resetHideTimer();
  }

  void seekTo(Duration position) {
    betterPlayerController?.seekTo(position);
    currentPosition.value = position;
    _resetHideTimer();
  }

  void _seek(Duration delta) {
    if (betterPlayerController == null || !isInitialized.value) return;
    final current = currentPosition.value;
    final target = current + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > totalDuration.value ? totalDuration.value : target);
    betterPlayerController!.seekTo(clamped);
    currentPosition.value = clamped;
  }

  void _showDoubleTapFeedback({bool left = false, bool right = false}) {
    if (left) {
      doubleTapLeft.value = true;
      Future.delayed(
        const Duration(milliseconds: 600),
        () => doubleTapLeft.value = false,
      );
    }
    if (right) {
      doubleTapRight.value = true;
      Future.delayed(
        const Duration(milliseconds: 600),
        () => doubleTapRight.value = false,
      );
    }
  }

  // ─── Controls visibility ───────────────────────────────────────────

  void toggleControls() {
    if (showControls.value) {
      showControls.value = false;
      _hideTimer?.cancel();
    } else {
      showControls.value = true;
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (isPlaying.value) showControls.value = false;
    });
  }

  void _resetHideTimer() {
    showControls.value = true;
    _startHideTimer();
  }

  // ─── Full screen ───────────────────────────────────────────────────

  Future<void> enterFullScreen() async {
    isFullScreen.value = true;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _resetHideTimer();
  }

  Future<void> exitFullScreen() async {
    isFullScreen.value = false;
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _resetHideTimer();
  }

  void toggleFullScreen() {
    if (isFullScreen.value) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
  }

  // ─── Picture in Picture ───────────────────────────────────────────

  Future<void> handlePiPButtonClick() async {
    if (betterPlayerController == null || !isInitialized.value) return;

    debugPrint('OttVideoPlayerController: Handling Mini Player activation');
    await switchToMiniPlayer();

    // Use a small delay to ensure the main BetterPlayer is unmounted
    // before the GlobalMiniPlayer mounts with the same GlobalKey.
    await Future.delayed(const Duration(milliseconds: 100));

    if (Get.currentRoute == AppRoutes.videoPlayer) {
      Get.back();
    }
  }

  void _attemptAutoPiP({int retryCount = 0}) {
    // Only attempt auto-PiP if OS supports it (Android 8.0+ or iOS 14+)
    bool supportsPip = false;
    if (GetPlatform.isAndroid) {
      // BetterPlayer internally handles API level checks, but we can be defensive
      supportsPip = true;
    } else if (GetPlatform.isIOS) {
      supportsPip = true;
    }

    if (!supportsPip || retryCount > 3 || isInPip.value || !isInitialized.value)
      return;

    enterPictureInPicture();

    // If not in PiP yet, try again shortly (max 3 times for stability)
    Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
      if (!isInPip.value &&
          (betterPlayerController?.videoPlayerController?.value.isPlaying ??
              false)) {
        debugPrint('OttVideoPlayerController: PiP retry #$retryCount');
        _attemptAutoPiP(retryCount: retryCount + 1);
      }
    });
  }

  void enterPictureInPicture() {
    if (betterPlayerController == null || !isInitialized.value) return;

    debugPrint(
      'OttVideoPlayerController: Requesting System PiP (Key: $betterPlayerKey)',
    );
    try {
      // better_player_plus will handle version checks internally and
      // do nothing if unsupported, preventing crashes on old versions.
      betterPlayerController!.enablePictureInPicture(betterPlayerKey);
    } catch (e) {
      debugPrint('OttVideoPlayerController: PiP error: $e');
    }
  }

  // ─── Player mode ───────────────────────────────────────────────────

  Future<void> showFullPlayer() async {
    // Reset state for a clean full-screen experience
    isLocked.value = false;
    videoFit.value = BoxFit.contain;
    isFullScreen.value = false;
    playerMode.value = PlayerDisplayMode.full;

    // ALWAYS force portrait orientation when opening the full player.
    // After PiP, the system orientation may still be landscape even though
    // isFullScreen was reset. This prevents the landscape→portrait flash.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Wait one frame for the orientation change to take effect before
    // navigating. This prevents the brief landscape flash.
    await Future.delayed(const Duration(milliseconds: 100));

    // If we are not on the video player screen, navigate to it
    if (Get.currentRoute != AppRoutes.videoPlayer) {
      Get.toNamed(
        AppRoutes.videoPlayer,
        arguments: {
          'videoUrl': _currentUrl,
          'title': videoTitle.value,
          'videoId': _videoId,
          'thumbnail': _videoThumbnail,
        },
      );
    }
  }

  Future<void> switchToMiniPlayer() async {
    if (isFullScreen.value) {
      await exitFullScreen();
    }
    // Reset lock and fit mode for clean mini player state
    isLocked.value = false;
    videoFit.value = BoxFit.contain;
    playerMode.value = PlayerDisplayMode.mini;
  }

  Future<void> hidePlayer() async {
    playerMode.value = PlayerDisplayMode.hidden;
    if (isFullScreen.value) {
      await exitFullScreen();
    }
  }

  Future<void> stopVideo() async {
    final controller = betterPlayerController;
    if (controller == null) return;

    try {
      await controller.pause();
      await controller.videoPlayerController?.pause();
      await controller.setVolume(0);
    } catch (_) {}

    isPlaying.value = false;
  }

  void setSubtitle(BetterPlayerAsmsTrack? track) {
    if (track == null) {
      betterPlayerController?.setTrack(BetterPlayerAsmsTrack.defaultTrack());
    } else {
      betterPlayerController?.setTrack(track);
    }
    currentSubtitle.value = track;
  }

  Future<void> closePlayer() async {
    debugPrint('OttVideoPlayerController: Closing player');

    _positionTimer?.cancel();
    _hideTimer?.cancel();
    _gestureTimer?.cancel();
    _fitLabelTimer?.cancel();
    try {
      await _pipChannel.invokeMethod('disable_auto_pip');
    } catch (_) {}

    final controller = betterPlayerController;

    if (controller != null) {
      try {
        controller.removeEventsListener(_onBetterPlayerEvent);

        await controller.setVolume(0);

        await controller.pause();

        await controller.videoPlayerController?.pause();

        // await controller.seekTo(Duration.zero);

        await Future.delayed(const Duration(milliseconds: 100));

        controller.dispose();
      } catch (e) {
        debugPrint('Dispose error: $e');
      }
    }

    betterPlayerController = null;

    isPlaying.value = false;
    isInitialized.value = false;
    isBuffering.value = false;
    isInPip.value = false;

    playerMode.value = PlayerDisplayMode.hidden;

    if (activeController.value == this) {
      activeController.value = null;
    }

    WakelockPlus.disable();

    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (_) {}

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Get.delete<OttVideoPlayerController>(force: true);
    playerMode.value = PlayerDisplayMode.hidden;

    isPlaying.value = false;
    isInitialized.value = false;
    isBuffering.value = false;
    isInPip.value = false;

    betterPlayerController = null;
  }

  // Future<void> closePlayer() async {
  //   debugPrint('OttVideoPlayerController: Force closing and disposing player');

  //   // Stop all tracking
  //   _positionTimer?.cancel();
  //   _hideTimer?.cancel();
  //   _gestureTimer?.cancel();
  //   _fitLabelTimer?.cancel();

  //   // Disable native auto-PiP since video is being closed
  //   _pipChannel.invokeMethod('disable_auto_pip');
  //   try {
  //     await betterPlayerController?.setVolume(0);
  //     await betterPlayerController?.pause();
  //     await betterPlayerController?.videoPlayerController?.pause();
  //   } catch (_) {
  //     try {
  //       await betterPlayerController?.setVolume(0);
  //       await betterPlayerController?.pause();
  //       await betterPlayerController?.videoPlayerController?.pause();
  //     } catch (_) {}
  //   }

  //   final controller = betterPlayerController;
  //   if (controller != null) {
  //     try {
  //       await controller.pause();
  //       await controller.videoPlayerController?.pause();
  //       // Clear surface to prevent 'ghost' video frames
  //       await controller.seekTo(Duration.zero);
  //     } catch (_) {}
  //   }

  //   playerMode.value = PlayerDisplayMode.hidden;

  //   if (activeController.value == this) {
  //     activeController.value = null;
  //   }

  //   // Small delay to ensure UI unmounts (SizedBox.shrink) before disposal
  //   await Future.delayed(const Duration(milliseconds: 50));

  //   try {
  //     betterPlayerController?.dispose();
  //   } catch (_) {}
  //   betterPlayerController = null;

  //   WakelockPlus.disable();
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  //   try {
  //     ScreenBrightness().resetScreenBrightness();
  //   } catch (_) {}

  //   isInitialized.value = false;
  //   isBuffering.value = false;
  //   isPlaying.value = false;

  //   onClose();
  // }

  // ─── Gesture Actions ──────────────────────────────────────────────

  void setVolume(double delta) {
    if (betterPlayerController == null) return;
    double newVolume = (volume.value + delta).clamp(0.0, 1.0);
    volume.value = newVolume;
    betterPlayerController!.setVolume(newVolume);

    showVolumeIndicator.value = true;
    _resetGestureTimer();
  }

  void setBrightness(double delta) {
    double newBrightness = (brightness.value + delta).clamp(0.0, 1.0);
    brightness.value = newBrightness;

    try {
      ScreenBrightness().setScreenBrightness(newBrightness);
    } catch (_) {}

    showBrightnessIndicator.value = true;
    _resetGestureTimer();
  }

  Timer? _gestureTimer;
  void _resetGestureTimer() {
    _gestureTimer?.cancel();
    _gestureTimer = Timer(const Duration(seconds: 2), () {
      showVolumeIndicator.value = false;
      showBrightnessIndicator.value = false;
    });
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
    if (isLocked.value) {
      showControls.value = false;
    } else {
      showControls.value = true;
      _startHideTimer();
    }
  }

  /// Toggle between Fit (contain) and Fill (cover) mode.
  ///
  /// Contain = video fits inside the screen with black bars.
  /// Cover   = video fills the entire screen, edges may be cropped.
  void toggleFillMode() {
    if (videoFit.value == BoxFit.contain) {
      videoFit.value = BoxFit.cover;
    } else {
      videoFit.value = BoxFit.contain;
    }
    _showFitLabel();
  }

  Timer? _fitLabelTimer;
  void _showFitLabel() {
    showFitModeLabel.value = true;
    _fitLabelTimer?.cancel();
    _fitLabelTimer = Timer(const Duration(milliseconds: 1200), () {
      showFitModeLabel.value = false;
    });
  }

  // ─── Utilities ─────────────────────────────────────────────────────

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────

  // @override
  // void onClose() {
  //   _trackWatchEvent(completed: _completionSent, force: true);
  //   _hideTimer?.cancel();
  //   _positionTimer?.cancel();

  //   // Ensure playback is fully stopped before disposing.
  //   final controller = betterPlayerController;
  //   if (controller != null) {
  //     controller.removeEventsListener(_onBetterPlayerEvent);
  //     // Pause the inner video player to stop audio immediately.
  //     try {
  //       controller.videoPlayerController?.setVolume(0);
  //       controller.pause();
  //       controller.videoPlayerController?.pause();
  //     } catch (_) {}
  //     controller.dispose();
  //   }
  //   betterPlayerController = null;
  //   isPlaying.value = false;
  //   isInitialized.value = false;
  //   isInitializing.value = false;

  //   // restore orientation & system UI
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (activeController.value == this) {
  //       activeController.value = null;
  //     }
  //   });
  //   WidgetsBinding.instance.removeObserver(this);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (activeController.value == this) {
  //       activeController.value = null;
  //     }
  //   });
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.onClose();
  // }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    _hideTimer?.cancel();
    _positionTimer?.cancel();
    _gestureTimer?.cancel();
    _fitLabelTimer?.cancel();

    WakelockPlus.disable();

    super.onClose();
  }
}

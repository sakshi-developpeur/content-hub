import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/audio_track_model.dart';
import 'package:estoriz/features/video_player/controllers/video_player_controller.dart';
import 'package:estoriz/features/video_player/controllers/settings_controller.dart';
import 'package:estoriz/features/video_player/presentation/controllers/addon_controller.dart';
import 'package:estoriz/features/video_player/presentation/widgets/addon_videos_section.dart';
import 'package:estoriz/features/video_player/view/ott_video_player.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';
import 'package:estoriz/features/video_player/presentation/widgets/live_chat_section.dart';
import 'package:estoriz/features/settings/controller/share_controller.dart';

import '../../watchlist/presentation/widgets/watchlist_button.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  final WatchHistoryRepository _watchHistoryRepository =
      WatchHistoryRepository();
  late SettingsController _settingsController;
  late OttVideoPlayerController _playerController;
  late ShareController _shareController;
  late AddonController _addonController;
  late String _title;
  late String _videoId;
  late String _contentId;
  late String _playerTag;
  String? _description;
  String? _videoUrl;
  String _thumbnail = '';
  int _resumeFromSeconds = 0;
  List<AudioTrackModel> _audioTracks = [];
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    final args =
        (Get.arguments as Map<String, dynamic>?) ?? <String, dynamic>{};
    _title = args['title']?.toString() ?? 'Untitled';
    _description = args['description']?.toString();
    _videoUrl = args['videoUrl']?.toString();
    _thumbnail = args['thumbnail']?.toString() ?? '';
    _videoId = args['id']?.toString() ?? '';
    _contentId = args['contentId']?.toString() ?? _videoId;
    int rawPos = _readInt(
      args['watchedPosition'] ?? args['lastPositionSeconds'],
    );
    int totalDur = _readInt(args['totalDuration']);

    // If the video was finished or nearly finished (within last 5s), restart from 0.
    if (totalDur > 0 && rawPos >= totalDur - 5) {
      _resumeFromSeconds = 0;
      debugPrint('VideoPlayerView: Video was finished, restarting from 0');
    } else {
      _resumeFromSeconds = rawPos;
    }

    _isLive = args['isLive'] == true;
    _playerTag = _videoId.trim().isNotEmpty
        ? _videoId
        : (_videoUrl ?? 'default_player');

    // Parse audio tracks from navigation arguments
    final rawTracks = args['audioTracks'];
    if (rawTracks is List) {
      _audioTracks = rawTracks
          .whereType<Map<String, dynamic>>()
          .map(AudioTrackModel.fromJson)
          .toList();
    }

    try {
      _settingsController = Get.find<SettingsController>();
    } catch (e) {
      _settingsController = SettingsController();
      Get.put<SettingsController>(_settingsController);
    }

    try {
      _playerController = Get.find<OttVideoPlayerController>(tag: _playerTag);
    } catch (e) {
      _playerController = Get.put(
        OttVideoPlayerController(),
        tag: _playerTag,
        permanent: true,
      );
    }

    // Wire settings controller to the player for audio track switching
    _settingsController.attachPlayer(_playerController);

    try {
      _shareController = Get.find<ShareController>();
    } catch (e) {
      _shareController = Get.put(ShareController());
    }

    _addonController = Get.find<AddonController>();
    _addonController.attachPlayerController(
      _playerController,
      fallbackVideoId: _videoId,
      fallbackThumbnail: _thumbnail,
    );
    _addonController.fetchAddonVideos(_contentId);
    _playerController.isViewAttached = true;

    _playerController.updateTitle(_title);
    _playerController.showFullPlayer();

    _resolveMissingVideoUrl();
  }

  Future<void> _resolveMissingVideoUrl() async {
    if ((_videoUrl ?? '').trim().isNotEmpty || _videoId.trim().isEmpty) {
      return;
    }

    final seed = WatchHistoryModel(
      videoId: _videoId,
      title: _title,
      thumbnail: _thumbnail,
      videoUrl: _videoUrl ?? '',
      totalDuration: 0,
      watchedPosition: _resumeFromSeconds,
      lastWatched: DateTime.now(),
    );

    final playable = await _watchHistoryRepository.ensurePlayableData(seed);
    if (!mounted) return;

    if (playable.videoUrl.trim().isEmpty) {
      return;
    }

    setState(() {
      _videoUrl = playable.videoUrl;
      if (_title == 'Untitled' && playable.title.trim().isNotEmpty) {
        _title = playable.title;
      }
      if (_thumbnail.trim().isEmpty && playable.thumbnail.trim().isNotEmpty) {
        _thumbnail = playable.thumbnail;
      }
    });
  }

  Future<void> _playFromWatchNow() async {
    // Already playing – nothing to do.
    if (_playerController.isPlaying.value) return;

    // If the controller finished initializing between taps, just resume.
    if (_playerController.isInitialized.value) {
      _playerController.togglePlayPause();
      return;
    }

    // OttVideoPlayer.didUpdateWidget may have already kicked off initVideo
    // (e.g. after _resolveMissingVideoUrl resolved asynchronously from initState).
    // Wait up to 15 s for it to complete instead of starting a duplicate init.
    if (_playerController.isInitializing.value) {
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_playerController.isInitialized.value) {
          if (!_playerController.isPlaying.value) {
            _playerController.togglePlayPause();
          }
          return;
        }
        if (!_playerController.isInitializing.value) break; // init failed
      }
    }

    // Resolve missing URL for history entries before trying to play.
    await _resolveMissingVideoUrl();

    // URL may now have been set and OttVideoPlayer.didUpdateWidget triggered
    // initVideo automatically. Re-check before calling it ourselves.
    if (_playerController.isInitialized.value) {
      if (!_playerController.isPlaying.value) {
        _playerController.togglePlayPause();
      }
      return;
    }

    final url = (_videoUrl ?? '').trim();
    if (url.isEmpty) {
      Get.snackbar(
        'Playback',
        'Video source not available. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    await _playerController.initVideo(
      url,
      autoPlay: true,
      videoId: _videoId,
      title: _title,
      thumbnail: _thumbnail,
      startPositionSeconds: _resumeFromSeconds,
      audioTracks: _audioTracks,
    );

    if (_playerController.isInitialized.value &&
        !_playerController.isPlaying.value) {
      _playerController.togglePlayPause();
    }
  }

  void _openSettingsSheet(BuildContext context) {
    const Color sheetColor = Color(0xFF1E1E1E);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Obx(() {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 0.6.sw : double.infinity,
                ),
                child: Container(
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 12.sp : 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildSettingsGroupEntry(
                      icon: Icons.translate_rounded,
                      title: 'Audio Language',
                      value: _settingsController.selectedLanguage.value,
                      onTap: () => _openLanguageSheet(sheetContext),
                    ),
                    SizedBox(height: 8.h),
                    _buildSettingsGroupEntry(
                      icon: Icons.hd_rounded,
                      title: 'Quality',
                      value: _settingsController.selectedQuality.value,
                      onTap: () => _openQualitySheet(sheetContext),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
      }),
    );
  }

  void _openLanguageSheet(BuildContext parentContext) {
    const Color sheetColor = Color(0xFF1E1E1E);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Navigator.of(parentContext).pop();
    Future.delayed(Duration.zero, () {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Obx(() {
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;
          final languages = _buildLanguageList();

          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? 0.6.sw : double.infinity,
                  ),
                  child: Container(
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 12.h),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Audio Language',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape ? 12.sp : 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (languages.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Text(
                            'No audio tracks available',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      else
                        ...languages.map(
                          (language) => _buildSettingOptionTile(
                            label: language,
                            selected:
                                _settingsController.selectedLanguage.value ==
                                language,
                            onTap: () {
                              _settingsController.setLanguage(language);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
        }),
      );
    });
  }

  /// Builds the list of available language names.
  ///
  /// Priority: HLS audio tracks (runtime) > API audio tracks (pre-loaded).
  /// Falls back to ['English', 'Hindi'] if neither source has data.
  List<String> _buildLanguageList() {
    // 1. Try HLS audio tracks from the player (most accurate, runtime)
    final hlsTracks = _playerController.hlsAudioTracks;
    if (hlsTracks.isNotEmpty) {
      final names = <String>{};
      for (final track in hlsTracks) {
        final label = track.label?.trim() ?? '';
        final lang = track.language?.trim() ?? '';
        if (label.isNotEmpty) {
          names.add(label);
        } else if (lang.isNotEmpty) {
          names.add(_codeToLanguageName(lang));
        }
      }
      if (names.isNotEmpty) return names.toList();
    }

    // 2. Try API audio tracks (pre-loaded metadata)
    final apiTracks = _playerController.apiAudioTracks;
    if (apiTracks.isNotEmpty) {
      final names = <String>{'English'}; // Default language is always English
      for (final track in apiTracks) {
        names.add(track.displayName);
      }
      return names.toList();
    }

    // 3. Fallback based on video's primary language + known API tracks
    if (_audioTracks.isNotEmpty) {
      final names = <String>{'English'};
      for (final track in _audioTracks) {
        names.add(track.displayName);
      }
      return names.toList();
    }

    // 4. Default fallback
    return ['English', 'Hindi'];
  }

  /// Converts language code to display name.
  String _codeToLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'hi':
        return 'Hindi';
      case 'en':
        return 'English';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'bn':
        return 'Bengali';
      case 'mr':
        return 'Marathi';
      case 'gu':
        return 'Gujarati';
      case 'kn':
        return 'Kannada';
      case 'ml':
        return 'Malayalam';
      case 'pa':
        return 'Punjabi';
      default:
        return code.toUpperCase();
    }
  }

  void _openQualitySheet(BuildContext parentContext) {
    const Color sheetColor = Color(0xFF1E1E1E);
    final List<String> qualities = ['Auto', '480p', '720p', '1080p'];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Navigator.of(parentContext).pop();
    Future.delayed(Duration.zero, () {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => Obx(() {
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? 0.6.sw : double.infinity,
                  ),
                  child: Container(
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 8.h),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 25.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Quality',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape ? 12.sp : 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      ...qualities.map(
                        (quality) => _buildSettingOptionTile(
                          label: quality,
                          selected:
                              _settingsController.selectedQuality.value ==
                              quality,
                          onTap: () {
                            _settingsController.setQuality(quality);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
        }),
      );
    });
  }

  Widget _buildSettingsGroupEntry({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Material(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12.r),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        leading: Icon(
          icon,
          color: Colors.white,
          size: isLandscape ? 18.sp : 20.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLandscape ? 12.sp : 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLandscape ? 10.sp : 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.white70),
      ),
    );
  }

  Widget _buildSettingOptionTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: selected ? Colors.white12 : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
          onTap: onTap,
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          trailing: Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.primary : Colors.white54,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  ButtonStyle _buildActionButtonStyle({Color? borderColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(
        color: borderColor ?? AppColors.surfaceVariant,
        width: 1.5,
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? borderColor,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: _buildActionButtonStyle(borderColor: borderColor),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerController.isViewAttached = false;
    _settingsController.detachPlayer();

    // Only cleanup/mute if we're NOT transitioning to mini or PiP mode.
    if (Get.isRegistered<OttVideoPlayerController>(tag: _playerTag)) {
      final controller = Get.find<OttVideoPlayerController>(tag: _playerTag);
      if (!controller.isInPip.value &&
          controller.playerMode.value != PlayerDisplayMode.mini) {
        // Fully stop playback to prevent audio leaks
        controller.closePlayer();
        Get.delete<OttVideoPlayerController>(tag: _playerTag, force: true);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Landscape / Fullscreen: video fills entire screen ──
      if (_playerController.isFullScreen.value) {
        return WillPopScope(
          onWillPop: () async {
            await _playerController.exitFullScreen();
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox.expand(
              child: OttVideoPlayer(
                videoUrl: _videoUrl ?? '',
                title: _title,
                videoId: _videoId,
                thumbnail: _thumbnail,
                startPositionSeconds: _resumeFromSeconds,
                tag: _playerTag,
                autoPlay: true,
                audioTracks: _audioTracks,
                onBack: () => _playerController.exitFullScreen(),
                onSettings: () => _openSettingsSheet(context),
              ),
            ),
          ),
        );
      }

      // ── Portrait: normal scrollable layout ──
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          top: true,
          child: Container(
            color: AppColors.scaffoldBackground,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: OttVideoPlayer(
                      videoUrl: _videoUrl ?? '',
                      title: _title,
                      videoId: _videoId,
                      thumbnail: _thumbnail,
                      startPositionSeconds: _resumeFromSeconds,
                      tag: _playerTag,
                      autoPlay: true,
                      audioTracks: _audioTracks,
                      onBack: () {
                        if (_playerController.isFullScreen.value) {
                          _playerController.exitFullScreen();
                          return;
                        }
                        // Back button in portrait: stop video and go back
                        _playerController.closePlayer();
                        Get.back();
                      },
                      onSettings: () => _openSettingsSheet(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: ElevatedButton.icon(
                        //         onPressed: () async {
                        //           if (_playerController.isPlaying.value) {
                        //             _playerController.togglePlayPause();
                        //             return;
                        //           }
                        //           _playerController.showFullPlayer();
                        //           await _playFromWatchNow();
                        //         },
                        //         icon: Icon(
                        //           Icons.play_arrow_rounded,
                        //           size: 22.sp,
                        //         ),
                        //         label: Text(
                        //           'Watch Now',
                        //           style: TextStyle(
                        //             fontSize: 14.sp,
                        //             fontWeight: FontWeight.w700,
                        //           ),
                        //         ),
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: AppColors.primary,
                        //           foregroundColor: Colors.white,
                        //           padding: EdgeInsets.symmetric(vertical: 13.h),
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10.r),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: WatchlistButton(
                                video: VideoModel(
                                  id: _videoId,
                                  title: _title,
                                  thumbnail: _thumbnail,
                                  videoUrl: _videoUrl ?? '',
                                ),
                                showLabel: true,
                                iconSize: 18.sp,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                  horizontal: 8.w,
                                ),
                                borderColor: AppColors.surfaceVariant,
                              ),
                            ),
                            // SizedBox(width: 8.w),
                            // Expanded(
                            //   child: _buildActionButton(
                            //     icon: Icons.share_rounded,
                            //     label: 'Share',
                            //     onPressed: () {
                            //       _shareController.shareVideo(
                            //         _title,
                            //         videoId: _videoId,
                            //       );
                            //     },
                            //   ),
                            // ),
                            if (_isLive) ...[
                              SizedBox(width: 8.w),
                              _buildHeartbeatButton(),
                            ],
                          ],
                        ),
                        if (_description != null &&
                            _description!.isNotEmpty) ...[
                          SizedBox(height: 24.h),
                          Text(
                            'About',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _description!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.sp,
                              height: 1.6,
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        if (_isLive)
                          const LiveChatSection()
                        else
                          AddonVideosSection(controller: _addonController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeartbeatButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: IconButton(
        onPressed: () {
          Get.snackbar(
            'Interaction',
            'Heartbeat sent!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
            icon: Icon(Icons.favorite_rounded, color: Colors.white),
          );
        },
        icon: Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22.sp)
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              duration: const Duration(milliseconds: 500),
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: const Duration(milliseconds: 500),
              begin: const Offset(1.2, 1.2),
              end: const Offset(1, 1),
              curve: Curves.easeInOut,
            ),
      ),
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

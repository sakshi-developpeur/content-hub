import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/audio_track_model.dart';
import 'package:estoriz/features/video_player/controllers/video_player_controller.dart';

class OttVideoPlayer extends StatefulWidget {
  const OttVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.videoId,
    this.thumbnail = '',
    this.startPositionSeconds = 0,
    this.tag,
    this.autoPlay = true,
    this.onBack,
    this.onSettings,
    this.audioTracks,
  });

  final String videoUrl;
  final String title;
  final String videoId;
  final String thumbnail;
  final int startPositionSeconds;
  final String? tag;
  final bool autoPlay;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final List<AudioTrackModel>? audioTracks;

  @override
  State<OttVideoPlayer> createState() => _OttVideoPlayerState();
}

class _OttVideoPlayerState extends State<OttVideoPlayer> {
  late final OttVideoPlayerController _controller;
  late final bool _ownsController;

  String get _tag => widget.tag ?? widget.videoUrl;

  @override
  void initState() {
    super.initState();
    _ownsController = !Get.isRegistered<OttVideoPlayerController>(tag: _tag);
    _controller = _ownsController
        ? Get.put(OttVideoPlayerController(), tag: _tag)
        : Get.find<OttVideoPlayerController>(tag: _tag);
    _controller.updateTitle(widget.title);
    _controller.initVideo(
      widget.videoUrl,
      autoPlay: widget.autoPlay,
      videoId: widget.videoId,
      title: widget.title,
      thumbnail: widget.thumbnail,
      startPositionSeconds: widget.startPositionSeconds,
      audioTracks: widget.audioTracks,
    );
  }

  @override
  void didUpdateWidget(covariant OttVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.videoId != widget.videoId ||
        oldWidget.startPositionSeconds != widget.startPositionSeconds) {
      _controller.initVideo(
        widget.videoUrl,
        autoPlay: widget.autoPlay,
        videoId: widget.videoId,
        title: widget.title,
        thumbnail: widget.thumbnail,
        startPositionSeconds: widget.startPositionSeconds,
        audioTracks: widget.audioTracks,
      );
    }
    if (oldWidget.title != widget.title) {
      _controller.updateTitle(widget.title);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<OttVideoPlayerController>(tag: _tag, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (_controller.playerMode.value) {
        case PlayerDisplayMode.full:
          return FullScreenPlayer(
            controller: _controller,
            title: widget.title,
            onBack: widget.onBack,
            onSettings: widget.onSettings,
          );
        case PlayerDisplayMode.mini:
        case PlayerDisplayMode.hidden:
          return const SizedBox.shrink();
      }
    });
  }
}

class FullScreenPlayer extends StatelessWidget {
  const FullScreenPlayer({
    super.key,
    required this.controller,
    required this.title,
    this.onBack,
    this.onSettings,
  });

  final OttVideoPlayerController controller;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: _PlayerShell(
        controller: controller,
        title: title,
        isFullScreen: true,
        onBackTap: onBack,
        onSettings: onSettings,
      ),
    );
  }
}

class _PlayerShell extends StatelessWidget {
  const _PlayerShell({
    required this.controller,
    required this.title,
    required this.isFullScreen,
    this.onBackTap,
    this.onSettings,
  });

  final OttVideoPlayerController controller;
  final String title;
  final bool isFullScreen;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.isLocked.value) {
          controller.toggleControls();
        } else {
          controller.toggleControls();
        }
      },
      onDoubleTapDown: (details) {
        if (controller.isLocked.value) return;
        final width = size.width;
        if (details.globalPosition.dx < width / 2) {
          controller.seekBackward();
        } else {
          controller.seekForward();
        }
      },
      onScaleStart: (details) {
        controller.isPinching.value = details.pointerCount > 1;
      },
      onScaleUpdate: (details) {
        if (controller.isLocked.value) return;

        // Two-finger pinch → toggle fill/fit
        if (details.pointerCount >= 2) {
          controller.isPinching.value = true;
          if (details.scale > 1.15 && !controller.isFillMode) {
            controller.toggleFillMode(); // zoom in → fill
          } else if (details.scale < 0.85 && controller.isFillMode) {
            controller.toggleFillMode(); // zoom out → fit
          }
          return;
        }

        // Single finger: Volume / Brightness (only if not pinching)
        if (details.pointerCount == 1 && !controller.isPinching.value) {
          final width = size.width;
          final delta = -details.focalPointDelta.dy / 250;

          if (details.focalPoint.dx < width / 3) {
            controller.setBrightness(delta);
          } else if (details.focalPoint.dx > width * 2 / 3) {
            controller.setVolume(delta);
          }
        }
      },
      onScaleEnd: (details) {
        controller.isPinching.value = false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _VideoSurface(controller: controller),

          // Gesture Indicators (Volume/Brightness HUD)
          _GestureIndicators(controller: controller),

          // Fit/Fill mode label (shown briefly on pinch)
          Obx(
            () => AnimatedOpacity(
              opacity: controller.showFitModeLabel.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Obx(
                    () => Text(
                      controller.isFillMode ? 'Fill' : 'Fit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Next Episode Overlay
          Obx(
            () => controller.showNextEpisodeCountdown.value
                ? _NextEpisodeOverlay(controller: controller)
                : const SizedBox.shrink(),
          ),

          Obx(
            () => AnimatedOpacity(
              opacity: controller.showControls.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: const _GradientOverlay(),
            ),
          ),
          _DoubleTapFeedback(controller: controller),
          Obx(
            () => IgnorePointer(
              ignoring: !controller.showControls.value,
              child: AnimatedOpacity(
                opacity: controller.showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: _Controls(
                  controller: controller,
                  title: title,
                  isFullScreen: isFullScreen,
                  onBackTap: onBackTap,
                  onSettings: onSettings,
                ),
              ),
            ),
          ),

          // Lock Button (Floating on the left)
          Obx(
            () => AnimatedOpacity(
              opacity: controller.showControls.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 24.w),
                  child: _PlayerIconButton(
                    icon: controller.isLocked.value
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    onTap: controller.toggleLock,
                    size: 14.r,
                    backgroundColor: Colors.black45,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () =>
                controller.isBuffering.value || controller.isInitializing.value
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _GestureIndicators extends StatelessWidget {
  final OttVideoPlayerController controller;
  const _GestureIndicators({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Brightness (Left)
        Obx(
          () => AnimatedOpacity(
            opacity: controller.showBrightnessIndicator.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _IndicatorCard(
                icon: Icons.brightness_high_rounded,
                value: controller.brightness.value,
                label: 'Brightness',
              ),
            ),
          ),
        ),
        // Volume (Right)
        Obx(
          () => AnimatedOpacity(
            opacity: controller.showVolumeIndicator.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerRight,
              child: _IndicatorCard(
                icon: Icons.volume_up_rounded,
                value: controller.volume.value,
                label: 'Volume',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final IconData icon;
  final double value;
  final String label;

  const _IndicatorCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14.sp),
          SizedBox(height: 8.h),
          Container(
            width: 2.5.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({required this.controller});

  final OttVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.betterPlayerController == null) {
        return const SizedBox.shrink();
      }

      final fit = controller.videoFit.value;

      Widget player = BetterPlayer(
        key: controller.betterPlayerKey,
        controller: controller.betterPlayerController!,
      );

      // For BoxFit.cover (fill mode), we clip the overflow and use
      // FittedBox to scale the video up to fill the entire screen.
      // For BoxFit.contain (fit mode), we just center the player.
      if (fit == BoxFit.cover) {
        return SizedBox.expand(
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).width / (16 / 9),
                child: player,
              ),
            ),
          ),
        );
      }

      return Center(child: player);
    });
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC000000),
            Colors.transparent,
            Colors.transparent,
            Color(0xCC000000),
          ],
          stops: [0.0, 0.25, 0.7, 1.0],
        ),
      ),
    );
  }
}

class _DoubleTapFeedback extends StatelessWidget {
  const _DoubleTapFeedback({required this.controller});

  final OttVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AnimatedOpacity(
              opacity: controller.doubleTapLeft.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.centerRight,
                    radius: 1.0,
                    colors: [Colors.white24, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fast_rewind_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '-10s',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedOpacity(
              opacity: controller.doubleTapRight.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.centerLeft,
                    radius: 1.0,
                    colors: [Colors.white24, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fast_forward_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+10s',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
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
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.title,
    required this.isFullScreen,
    this.onSettings,
    this.onBackTap,
  });

  final OttVideoPlayerController controller;
  final String title;
  final bool isFullScreen;
  final VoidCallback? onSettings;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLocked.value) {
        return const SizedBox.shrink(); // Lock button is handled in _PlayerShell stack
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _TopBar(
              controller: controller,
              title: title,
              isFullScreen: isFullScreen,
              onBackTap: onBackTap,
              onSettings: onSettings,
              onPiPTap: () => controller.handlePiPButtonClick(),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _CenterRow(controller: controller),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              controller: controller,
              isFullScreen: isFullScreen,
            ),
          ),
        ],
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    required this.title,
    required this.isFullScreen,
    this.onBackTap,
    this.onSettings,
    this.onPiPTap,
  });

  final OttVideoPlayerController controller;
  final String title;
  final bool isFullScreen;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettings;
  final VoidCallback? onPiPTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = isFullScreen ? 16.r : 20.r;
    final fontSize = isFullScreen ? 14.r : 16.r;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        child: Row(
          children: [
            if (onBackTap != null)
              _PlayerIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBackTap,
                size: iconSize,
              ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // if (onPiPTap != null)
            //   _PlayerIconButton(
            //     icon: Icons.picture_in_picture_alt_rounded,
            //     onTap: onPiPTap,
            //     size: iconSize,
            //   ),
            // Obx(
            //   () => _PlayerIconButton(
            //     icon: controller.isFillMode.value
            //         ? Icons.fullscreen_exit_rounded
            //         : Icons.fullscreen_rounded,
            //     onTap: controller.toggleAspectRatio,
            //     size: iconSize,
            //   ),
            // ),
            if (onSettings != null)
              _PlayerIconButton(
                icon: Icons.more_vert_rounded,
                onTap: onSettings,
                size: iconSize,
              ),
          ],
        ),
      ),
    );
  }
}

class _CenterRow extends StatelessWidget {
  const _CenterRow({required this.controller});

  final OttVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReady = controller.isInitialized.value;
      final isPlaying = controller.isPlaying.value;
      final inFullScreen = controller.isFullScreen.value;
      final playIconSize = inFullScreen ? 32.r : 30.r;
      final seekIconSize = inFullScreen ? 20.r : 22.r;
      final padding = inFullScreen ? 12.r : 14.r;
      final spacing = inFullScreen ? 40.w : 32.w;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SeekButton(
            icon: Icons.replay_10_rounded,
            onTap: isReady ? controller.seekBackward : null,
            size: seekIconSize,
          ),
          SizedBox(width: spacing),
          GestureDetector(
            onTap: isReady ? controller.togglePlayPause : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.all(padding),
              decoration: const BoxDecoration(
                color: Color(0xFF5D38FF), // Purple/Blue as per image
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: playIconSize,
              ),
            ),
          ),
          SizedBox(width: spacing),
          _SeekButton(
            icon: Icons.forward_10_rounded,
            onTap: isReady ? controller.seekForward : null,
            size: seekIconSize,
          ),
        ],
      );
    });
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller, required this.isFullScreen});

  final OttVideoPlayerController controller;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final position = controller.currentPosition.value;
      final duration = controller.totalDuration.value;
      final inFullScreen = controller.isFullScreen.value;
      final progress = duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;
      final durationFontSize = inFullScreen ? 10.r : 12.r;
      final separatorFontSize = inFullScreen ? 8.r : 10.r;
      final buttonSize = inFullScreen ? 18.r : 20.r;
      final padding = inFullScreen ? 16.w : 12.w;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 6.h, padding, 6.h),
              child: Row(
                children: [
                  Text(
                    controller.formatDuration(position),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: durationFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '  /  ',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: separatorFontSize,
                    ),
                  ),
                  Text(
                    controller.formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: durationFontSize,
                    ),
                  ),
                  const Spacer(),
                  // Fill/Fit toggle (landscape only)
                  // if (controller.isFullScreen.value)
                  //   Obx(
                  //     () => _PlayerIconButton(
                  //       icon: controller.isFillMode
                  //           ? Icons.fit_screen_rounded
                  //           : Icons.crop_free_rounded,
                  //       onTap: controller.toggleFillMode,
                  //       size: buttonSize,
                  //     ),
                  //   ),
                  _PlayerIconButton(
                    icon: controller.isFullScreen.value
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    onTap: controller.toggleFullScreen,
                    size: buttonSize,
                  ),
                ],
              ),
            ),
          ),
          _YoutubeProgressBar(
            progress: progress.clamp(0.0, 1.0),
            enabled: controller.isInitialized.value,
            onSeek: (value) {
              final target = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              controller.seekTo(target);
            },
          ),
        ],
      );
    });
  }
}

class _YoutubeProgressBar extends StatelessWidget {
  const _YoutubeProgressBar({
    required this.progress,
    required this.enabled,
    required this.onSeek,
  });

  final double progress;
  final bool enabled;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final barHeight = isLandscape ? 24.r : 28.r;

    return SizedBox(
      height: barHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbSize = isLandscape ? 12.r : 12.r;
          final normalizedProgress = progress.clamp(0.0, 1.0);

          double normalize(double dx) {
            if (constraints.maxWidth <= 0) return 0;
            return (dx / constraints.maxWidth).clamp(0.0, 1.0);
          }

          final thumbLeft =
              ((constraints.maxWidth - thumbSize) * normalizedProgress).clamp(
                0.0,
                constraints.maxWidth - thumbSize,
              );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (details) => onSeek(normalize(details.localPosition.dx))
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) => onSeek(normalize(details.localPosition.dx))
                : null,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: isLandscape ? 8.r : 5.r,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: normalizedProgress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: isLandscape ? 8.r : 5.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbLeft,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.icon,
    required this.onTap,
    this.size,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double? size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: backgroundColor != null ? EdgeInsets.all(4.r) : null,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size ?? 20.sp),
      ),
      splashRadius: 16.r,
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({required this.icon, required this.onTap, this.size = 18});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

class _NextEpisodeOverlay extends StatelessWidget {
  final OttVideoPlayerController controller;
  const _NextEpisodeOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Next Episode in',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                '${controller.nextEpisodeTimerSeconds.value}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Trigger next episode logic
                controller.showNextEpisodeCountdown.value = false;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              ),
              child: const Text('Play Now'),
            ),
            TextButton(
              onPressed: () =>
                  controller.showNextEpisodeCountdown.value = false,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

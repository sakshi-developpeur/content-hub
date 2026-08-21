import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/video_player/controllers/video_player_controller.dart';

class GlobalMiniPlayer extends StatefulWidget {
  const GlobalMiniPlayer({super.key});

  @override
  State<GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends State<GlobalMiniPlayer> {
  Offset offset = Offset(200.w, 500.h); // Initial position

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = OttVideoPlayerController.activeController.value;
      if (controller == null ||
          controller.playerMode.value != PlayerDisplayMode.mini) {
        return const SizedBox.shrink();
      }

      final double width = 180.w;
      final double height = 100.h;

      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    offset += details.delta;

                    // Boundary checks
                    final size = MediaQuery.of(context).size;
                    if (offset.dx < 0) offset = Offset(0, offset.dy);
                    if (offset.dy < 0) offset = Offset(offset.dx, 0);
                    if (offset.dx > size.width - width) {
                      offset = Offset(size.width - width, offset.dy);
                    }
                    if (offset.dy > size.height - height - 120.h) {
                      offset = Offset(offset.dx, size.height - height - 120.h);
                    }
                  });
                },
                onTap: () {
                  controller.showFullPlayer();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Video Frame
                      RepaintBoundary(
                        child: BetterPlayer(
                          key: controller.betterPlayerKey,
                          controller: controller.betterPlayerController!,
                        ),
                      ),
                      // Transparent layer to capture drag events
                      Positioned.fill(
                        child: Container(color: Colors.transparent),
                      ),
                      // Overlay Controls
                      Obx(() => controller.isInPip.value 
                        ? const SizedBox.shrink()
                        : Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Play/Pause
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    controller.isPlaying.value
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.primary,
                                    size: 20.sp,
                                  ),
                                  onPressed: controller.togglePlayPause,
                                ),
                                // Full Screen
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    controller.showFullPlayer();
                                  },
                                ),
                                // Close
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  onPressed: () {
                                    controller.closePlayer();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

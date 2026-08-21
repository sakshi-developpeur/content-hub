import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import '../controllers/live_player_controller.dart';

class LivePlayerView extends GetView<LivePlayerController> {
  const LivePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState();
          }
          if (!controller.isJoined.value) {
            return _buildLoadingState();
          }
          return _buildPlayerContent();
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Joining Livestream...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error joining stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.leaveStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerContent() {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return Stack(
            children: [
              // Full screen video
              Positioned.fill(child: _buildVideoSurface()),
              // Overlaid controls
              _buildTopBar(isLandscape: true),
              // Optional: Small overlay for info or viewer count if needed
            ],
          );
        }

        return Column(
          children: [
            // Top section: Video Player Area (Fixed Aspect Ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  _buildVideoSurface(),
                  _buildTopBar(isLandscape: false),
                ],
              ),
            ),

            // Bottom section: Info, Interaction
            Expanded(
              child: Container(
                color: AppColors.scaffoldBackground,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildStreamInfo()],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoSurface() {
    return Obx(() {
      if (controller.remoteUid.value == 0) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Connecting to host...',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        );
      }
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.engine,
          canvas: VideoCanvas(
            uid: controller.remoteUid.value,
            renderMode: RenderModeType
                .renderModeHidden, // Maintain aspect ratio while filling
          ),
          connection: RtcConnection(
            channelId: controller.agoraDetails.channelName,
          ),
        ),
      );
    });
  }

  Widget _buildTopBar({bool isLandscape = false}) {
    // Further reduce sizes in landscape mode
    final double iconSize = isLandscape ? 20 : 28;
    final double badgeTextSize = isLandscape ? 9 : 11.sp;
    final double viewerTextSize = isLandscape ? 9 : 12.sp;
    final double horizontalPadding = isLandscape ? 6 : 10.w;
    final double verticalPadding = isLandscape ? 2 : 5.h;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 16 : 8.w,
          vertical: isLandscape ? 4 : 8.h,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: controller.leaveStream,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isLandscape ? 3 : 6,
                    height: isLandscape ? 3 : 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeTextSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Obx(
                () => Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: isLandscape ? 12 : 14,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '${controller.viewerCount.value}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: viewerTextSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              icon: Icon(
                isLandscape
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: controller.toggleOrientation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.currentEvent.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF64B5F6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    controller.currentEvent.hostName
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'H',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentEvent.hostName ?? 'Host Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Principal Instructor',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeartbeatButton(),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'About this Session',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            controller.currentEvent.description ??
                'No description provided for this session.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
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
          // You could also call an API here if required for manual heartbeat/likes
          Get.snackbar(
            'Interaction',
            'Heartbeat sent!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
            icon: const Icon(Icons.favorite_rounded, color: Colors.white),
            duration: const Duration(seconds: 1),
          );
        },
        icon: Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22.sp)
            .animate(onPlay: (c) => c.repeat())
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
}

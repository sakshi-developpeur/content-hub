import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';
import 'package:estoriz/features/watchlist/presentation/controllers/watchlist_controller.dart';

class WatchlistScreen extends GetView<WatchlistController> {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Watchlist',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.watchlist.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.watchlist.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadWatchlist,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            itemCount: controller.watchlist.length,
            itemBuilder: (context, index) {
              final video = controller.watchlist[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _WatchlistTile(video: video),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.textHint,
              size: 58.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'Your watchlist is empty',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Save videos from any card or player and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WatchlistScreen();
  }
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatchlistController>();

    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => controller.openWatchlistVideo(video),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              SizedBox(
                width: 116.w,
                height: 68.h,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: SizedBox(
                        width: 116.w,
                        height: 68.h,
                        child: _thumbnail(video.thumbnail),
                      ),
                    ),
                    if (video.totalDuration > 0 && video.watchedPosition > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.r),
                            bottomRight: Radius.circular(8.r),
                          ),
                          child: LinearProgressIndicator(
                            minHeight: 4.h,
                            value: (video.watchedPosition / video.totalDuration)
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.black45,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (video.totalDuration > 0 &&
                        video.watchedPosition > 0) ...[
                      SizedBox(height: 6.h),
                      Text(
                        '${_formatDuration(video.watchedPosition)} / ${_formatDuration(video.totalDuration)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final removed = await controller.removeFromWatchlist(
                    video.id,
                  );
                  if (!removed) {
                    return;
                  }

                  Get.snackbar(
                    'Watchlist',
                    'Removed from watchlist',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(String url) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: Icon(Icons.movie_rounded, color: Colors.white24, size: 28.sp),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, imageUrl) => Container(color: AppColors.surface),
      errorWidget: (context, imageUrl, error) => Container(
        color: AppColors.surface,
        child: Icon(Icons.movie_rounded, color: Colors.white24, size: 28.sp),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$remainingSeconds';
    }
    return '$minutes:$remainingSeconds';
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/presentation/controllers/watch_history_controller.dart';

class HistoryVideoCard extends StatelessWidget {
  const HistoryVideoCard({super.key, required this.video});

  final WatchHistoryModel video;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatchHistoryController>();
    final progress = controller.getProgress(video);

    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final playable = await controller.prepareForPlayback(video);
          if (playable.videoUrl.trim().isEmpty &&
              playable.videoId.trim().isEmpty) {
            Get.snackbar(
              'Playback',
              'Video source is unavailable right now.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
            return;
          }

          Get.toNamed(
            AppRoutes.videoPlayer,
            arguments: {
              'id': playable.videoId,
              'title': playable.title,
              'thumbnail': playable.thumbnail,
              'videoUrl': playable.videoUrl,
              'lastPositionSeconds': playable.watchedPosition,
              'watchedPosition': playable.watchedPosition,
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120.w,
                      height: 70.h,
                      child: _buildThumb(video.thumbnail),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3.h,
                        backgroundColor: const Color(0x66333333),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
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
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatLastWatched(video.lastWatched),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb(String url) {
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

  String _formatLastWatched(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value.toLocal());

    if (diff.inMinutes < 1) return 'Last watched just now';
    if (diff.inHours < 1) return 'Last watched ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Last watched ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Last watched ${diff.inDays}d ago';

    return 'Last watched ${DateFormat('dd MMM, hh:mm a').format(value.toLocal())}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_cached_image.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';
import 'package:estoriz/features/video_player/presentation/controllers/addon_controller.dart';

class AddonVideosSection extends StatelessWidget {
  const AddonVideosSection({super.key, required this.controller});

  final AddonController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Videos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.isLoading.value) {
            return SizedBox(
              height: 158.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => _buildLoadingCard(),
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemCount: 3,
              ),
            );
          }

          if (controller.addonVideos.isEmpty) {
            final hasError = controller.errorMessage.value.trim().isNotEmpty;
            return _buildEmptyState(
              hasError
                  ? controller.errorMessage.value
                  : 'No related videos available.',
            );
          }

          return SizedBox(
            height: 190.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.addonVideos.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final video = controller.addonVideos[index];
                return _AddonVideoCard(
                  video: video,
                  onTap: () => controller.playAddonVideo(video),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 210.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AddonVideoCard extends StatelessWidget {
  const _AddonVideoCard({required this.video, required this.onTap});

  final AddonVideoModel video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        width: 210.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Stack(
                  children: [
                    _buildThumbnail(),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (video.thumbnailUrl.trim().isEmpty) {
      return Container(
        height: 118.h,
        width: double.infinity,
        color: AppColors.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(
          Icons.ondemand_video_rounded,
          color: AppColors.textHint,
          size: 28.sp,
        ),
      );
    }

    return AppCachedImage.rounded(
      imageUrl: video.thumbnailUrl,
      borderRadius: 10,
      height: 118,
      width: 194,
      fit: BoxFit.cover,
      backgroundColor: AppColors.surfaceVariant,
    );
  }

  String _formatDuration(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final hours = safe ~/ 3600;
    final minutes = (safe % 3600) ~/ 60;
    final secs = safe % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/video_list_model.dart';
import 'package:estoriz/features/home/presentation/controllers/video_list_controller.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';
import 'package:estoriz/features/watchlist/presentation/widgets/watchlist_button.dart';

class VideoListView extends GetView<VideoListController> {
  const VideoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: Text(
          'Videos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.videos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white38,
                  size: 56.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: controller.fetchVideosByCategory,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_rounded,
                  color: Colors.white38,
                  size: 56.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No videos found',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.6,
          ),
          itemCount: controller.videos.length,
          itemBuilder: (_, index) {
            final video = controller.videos[index];
            return _VideoCard(video: video);
          },
        );
      }),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.videoPlayer,
          arguments: {
            'id': video.id,
            'title': video.title,
            'thumbnail': video.thumbnail,
            'description': video.description,
            'duration': video.duration,
            'videoUrl': video.videoUrl,
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 150.h,
                  child: _VideoThumbnail(imageUrl: video.thumbnail),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: WatchlistButton(
                  video: VideoModel(
                    id: video.id,
                    title: video.title,
                    thumbnail: video.thumbnail,
                    videoUrl: video.videoUrl ?? '',
                  ),
                  iconSize: 18,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  backgroundColor: Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (video.rating != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        video.rating!.toStringAsFixed(1),
                        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.video_library_rounded,
          color: Colors.white24,
          size: 40.sp,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, imageUrl) =>
          Container(color: AppColors.surfaceVariant),
      errorWidget: (context, imageUrl, error) => Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.video_library_rounded,
          color: Colors.white24,
          size: 40.sp,
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/recommendation_model.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';

class RecommendationSection extends GetView<HomeController> {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isRecommendationsLoading.value) {
        return const _RecommendationSkeleton();
      }

      // Only show recommendations with a valid videoUrl
      final items = controller.recommendations
          .where(
            (item) =>
                (item.videoUrl != null && item.videoUrl!.trim().isNotEmpty),
          )
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendations',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                // Text(
                //   'Picked based on your recent watch pattern',
                //   style: TextStyle(
                //     color: AppColors.textSecondary,
                //     fontSize: 11.sp,
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  'No recommendations video available right now.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 188.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final recommendation = items[i];
                  return _RecommendationCard(
                    index: i,
                    item: recommendation,
                    onTap: () => controller.onRecommendationTap(recommendation),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

class _RecommendationCard extends StatelessWidget {
  final int index;
  final RecommendationItem item;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.index,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GestureDetector(
      onTap: item.videoUrl != null && item.videoUrl!.trim().isNotEmpty
          ? onTap
          : () {
              Get.snackbar(
                'Unavailable',
                'This recommendation does not have a playable video.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
      child: Container(
        width: 278.w,
        margin: EdgeInsets.only(right: 14.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.surfaceVariant,
          border: Border.all(color: const Color(0xFF3B337A), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.thumbnail,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surfaceVariant),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.movie_rounded,
                  color: Colors.white24,
                  size: 42.sp,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x1AFFFFFF),
                    Color(0x8A16073E),
                    Color(0xF20C042E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            if (controller.hasWatchProgress(item.id))
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  minHeight: 4.h,
                  value: controller.progressValueFor(item.id),
                  backgroundColor: Colors.black45,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF11B5D9).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  'TOP ${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(99.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 15.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Watch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.category != null && item.category!.isNotEmpty)
                    Text(
                      item.category!.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 3.h),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 7),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.duration != null && item.duration!.isNotEmpty) ...[
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12.sp,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          item.duration!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationSkeleton extends StatelessWidget {
  const _RecommendationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: 180.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 188.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 278.w,
              margin: EdgeInsets.only(right: 14.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_cached_image.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/category_model.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';
import 'package:estoriz/features/home/presentation/widgets/section_header.dart';

/// "Popular Now" â€” portrait card row
class CategorySection extends GetView<HomeController> {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) {
        return _CategorySkeleton();
      }
      if (controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Categories List',
            onSeeAll: () {
              Get.toNamed('/seeAll', arguments: {'type': 'categories'});
            },
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 228.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.categories.length,
              itemBuilder: (_, i) {
                final category = controller.categories[i];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _CategoryCard(
                    category: category,
                    onTap: () => controller.onCategoryTap(category),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 160.w,
                height: 175.h,
                child: _CategoryImage(imageUrl: category.imageUrl),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              category.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AppCachedImage.rounded(imageUrl: imageUrl, fit: BoxFit.fill);
    //   if (imageUrl.isEmpty) {
    //     return Container(
    //       width: double.infinity,
    //       height: double.infinity,
    //       color: AppColors.surfaceVariant,
    //       child: Icon(
    //         Icons.grid_view_rounded,
    //         color: Colors.white24,
    //         size: 36.sp,
    //       ),
    //     );
    //   }

    //   return CachedNetworkImage(
    //     imageUrl: imageUrl,
    //     width: double.infinity,
    //     height: double.infinity,
    //     fit: BoxFit.fill,
    //     placeholder: (_, _) => Container(
    //       width: double.infinity,
    //       height: double.infinity,
    //       color: AppColors.surfaceVariant,
    //     ),
    //     errorWidget: (_, __, ___) => Container(
    //       width: double.infinity,
    //       height: double.infinity,
    //       color: AppColors.surfaceVariant,
    //       child: Icon(
    //         Icons.grid_view_rounded,
    //         color: Colors.white24,
    //         size: 36.sp,
    //       ),
    //     ),
    //   );
  }
}

/// "New on OTT" â€” wide landscape card row
class NewOnOttSection extends GetView<HomeController> {
  const NewOnOttSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isVideosLoading.value) {
        return const _NewOnOttSkeleton();
      }
      if (controller.videos.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'New on Estoriz',
            onSeeAll: () {
              Get.toNamed('/seeAll', arguments: {'type': 'newOnEstoriz'});
            },
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 108.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.videos.length,
              itemBuilder: (_, i) {
                final video = controller.videos[i];
                return GestureDetector(
                  onTap: () => controller.onVideoTap(video),
                  child: Container(
                    width: 186.w,
                    margin: EdgeInsets.only(right: 12.w),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: AppColors.surfaceVariant,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: video.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.surfaceVariant),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceVariant,
                            child: Icon(
                              Icons.movie_rounded,
                              color: Colors.white24,
                              size: 32.sp,
                            ),
                          ),
                        ),
                        if (controller.hasWatchProgress(video.id))
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: LinearProgressIndicator(
                              minHeight: 4.h,
                              value: controller.progressValueFor(video.id),
                              backgroundColor: Colors.black45,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xCC0C042E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Text(
                              video.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: 140.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 228.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130.w,
                    height: 175.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 100.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewOnOttSkeleton extends StatelessWidget {
  const _NewOnOttSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: 120.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 108.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              width: 186.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

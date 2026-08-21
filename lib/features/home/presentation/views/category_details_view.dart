import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/category_details_model.dart';
import 'package:estoriz/features/home/data/models/video_list_model.dart';
import 'package:estoriz/features/home/presentation/controllers/category_details_controller.dart';

class CategoryDetailsView extends GetView<CategoryDetailsController> {
  const CategoryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty ||
            controller.category.value == null) {
          return _CategoryErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.fetchCategoryDetails,
          );
        }

        final category = controller.category.value!;
        return CustomScrollView(
          slivers: [
            _CategoryHero(category: category),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IdentityCard(category: category),
                    if (category.tags.isNotEmpty) ...[
                      SizedBox(height: 18.h),
                      _TagCloudCard(tags: category.tags),
                    ],
                    SizedBox(height: 18.h),
                    _MetaGrid(category: category),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({required this.category});

  final CategoryDetailsItem category;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320.h,
      pinned: true,
      backgroundColor: AppColors.scaffoldBackground,
      leading: IconButton(
        onPressed: Get.back,
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _HeroImage(
              imageUrl: category.bannerUrl.isNotEmpty
                  ? category.bannerUrl
                  : category.imageUrl,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    AppColors.scaffoldBackground.withValues(alpha: 0.35),
                    AppColors.scaffoldBackground,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 18.w,
              right: 18.w,
              bottom: 26.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(Icons.category_rounded, color: Colors.white24, size: 72.sp),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      placeholder: (_, _) => Container(color: AppColors.surfaceVariant),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: Icon(Icons.category_rounded, color: Colors.white24, size: 72.sp),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.category});

  final CategoryDetailsItem category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1F1448), const Color(0xFF311B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFF5A46E8).withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              width: 92.w,
              height: 92.w,
              child: _HeroImage(imageUrl: category.imageUrl),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _StatusPill(
                      label: category.isActive ? 'Active' : 'Inactive',
                      color: category.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    _StatusPill(
                      label: 'Order ${category.order}',
                      color: const Color(0xFF11B5D9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagCloudCard extends StatelessWidget {
  const _TagCloudCard({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: 'Category Signals',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: tags
            .map(
              (tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.category});

  final CategoryDetailsItem category;

  static const List<Color> _accents = [
    Color(0xFFE4572E),
    Color(0xFF11B5D9),
    Color(0xFF7ED957),
    Color(0xFFF9C74F),
    Color(0xFFB44FFF),
    Color(0xFFFF6B9D),
  ];

  @override
  Widget build(BuildContext context) {
    final children = category.children;
    if (children.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.18,
      children: List.generate(children.length, (i) {
        final child = children[i];
        return _MetricCard(
          label: child.name,
          accent: _accents[i % _accents.length],
          categoryId: child.id,
          thumbnailUrl: child.thumbnailUrl,
        );
      }),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.accent,
    required this.categoryId,
    required this.thumbnailUrl,
  });

  final String label;
  final Color accent;
  final String categoryId;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryDetailsController>();
    return GestureDetector(
      onTap: () {
        controller.fetchCategoryVideos(categoryId);
        _showVideosBottomSheet(context, categoryId, label);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.18),
              AppColors.surfaceVariant.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl.trim().isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceVariant),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: AppColors.surfaceVariant,
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              if (thumbnailUrl.trim().isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CategoryErrorState extends StatelessWidget {
  const _CategoryErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              color: AppColors.textHint,
              size: 60.sp,
            ),
            SizedBox(height: 14.h),
            Text(
              'Unable to load category',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message.isEmpty ? 'Something went wrong.' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showVideosBottomSheet(
  BuildContext context,
  String categoryId,
  String categoryLabel,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _VideosBottomSheet(
        categoryId: categoryId,
        categoryLabel: categoryLabel,
      );
    },
  );
}

class _VideosBottomSheet extends StatelessWidget {
  const _VideosBottomSheet({
    required this.categoryId,
    required this.categoryLabel,
  });

  final String categoryId;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryDetailsController>();

    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      initialChildSize: 0.7,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      snapSizes: const [0.25, 0.7, 1.0],
      shouldCloseOnMinExtent: true,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Container(
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isVideosLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.videosErrorMessage.value.isNotEmpty) {
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
                            controller.videosErrorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.categoryVideos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            color: Colors.white38,
                            size: 56.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No videos found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: controller.categoryVideos.length,
                    itemBuilder: (context, index) {
                      final video = controller.categoryVideos[index];
                      return _VideoTile(video: video);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.toNamed(
          AppRoutes.videoPlayer,
          arguments: {
            'id': video.id,
            'title': video.title,
            'description': video.description ?? '',
            'duration': video.duration?.toString() ?? '',
            'videoUrl': video.videoUrl ?? '',
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: video.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceVariant),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.video_library_outlined,
                    color: Colors.white38,
                    size: 32.sp,
                  ),
                ),
              ),
            ),
            Container(
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
            ),
            Positioned(
              bottom: 12.r,
              left: 12.r,
              right: 12.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


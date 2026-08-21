import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/data/models/banner_model.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';

class BannerWidget extends GetView<HomeController> {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isBannerLoading.value) {
        return _BannerSkeleton();
      }
      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 480.h,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              itemCount: controller.banners.length,
              onPageChanged: (i) => controller.currentBannerIndex.value = i,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => controller.onBannerTap(controller.banners[i]),
                child: _BannerSlide(banner: controller.banners[i]),
              ),
            ),
            // Dot indicator
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.banners.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: controller.currentBannerIndex.value == i
                          ? 22.w
                          : 6.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: controller.currentBannerIndex.value == i
                            ? AppColors.primary
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480.h,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final BannerItem banner;
  const _BannerSlide({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail
        CachedNetworkImage(
          imageUrl: banner.thumbnail,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.surfaceVariant),
          errorWidget: (_, _, _) => Container(
            color: AppColors.surfaceVariant,
            child: Icon(
              Icons.movie_rounded,
              color: Colors.white24,
              size: 80.sp,
            ),
          ),
        ),
        // Gradient overlay â€” transparent â†’ black for legibility
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0x990C042E),
                Color(0xFF0C042E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.35, 0.72, 1.0],
            ),
          ),
        ),
        // Text + buttons
        Positioned(
          bottom: 42.h,
          left: 20.w,
          right: 20.w,
          child: _BannerContent(banner: banner),
        ),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  final BannerItem banner;
  const _BannerContent({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          banner.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            height: 1.2,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (banner.description != null && banner.description!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            banner.description!,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (banner.duration != null && banner.duration!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Colors.white38,
                size: 13.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                banner.duration!,
                style: TextStyle(color: Colors.white38, fontSize: 11.sp),
              ),
            ],
          ),
        ],
        SizedBox(height: 16.h),
        Row(
          children: [
            _PlayButton(
              onPressed: () => Get.find<HomeController>().onBannerTap(banner),
            ),
            SizedBox(width: 10.w),
            // _MyListButton(),
          ],
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.play_arrow_rounded, size: 22.sp, color: Colors.black),
      label: Text(
        'Play',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      ),
    );
  }
}

// class _MyListButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: () {},
//       icon: Icon(Icons.add_rounded, size: 20.sp, color: Colors.white),
//       label: Text(
//         'My List',
//         style: TextStyle(fontSize: 13.sp, color: Colors.white70),
//       ),
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: Colors.white38),
//         padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
//       ),
//     );
//   }
// }

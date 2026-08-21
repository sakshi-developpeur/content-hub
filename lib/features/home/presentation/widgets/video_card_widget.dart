import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';

class VideoCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double cardWidth;
  final double cardHeight;

  const VideoCard({
    super.key,
    required this.thumbnail,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.cardWidth = 130,
    this.cardHeight = 175,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: thumbnail,
                width: cardWidth.w,
                height: cardHeight.h,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    _Skeleton(width: cardWidth.w, height: cardHeight.h),
                errorWidget: (_, _, _) =>
                    _ErrorPlaceholder(width: cardWidth.w, height: cardHeight.h),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;
  const _Skeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  const _ErrorPlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.movie_rounded, color: Colors.white24, size: 36.sp),
    );
  }
}


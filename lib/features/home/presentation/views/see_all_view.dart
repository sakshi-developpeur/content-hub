import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';
import 'package:estoriz/features/home/data/models/category_model.dart';
import 'package:estoriz/features/home/data/models/recommendation_model.dart';

class SeeAllView extends GetView<HomeController> {
  final SeeAllType type;
  const SeeAllView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: Text(
          type == SeeAllType.categories ? 'All Categories' : 'New on Estoriz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() {
        if (type == SeeAllType.categories) {
          if (controller.isCategoriesLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.categories.isEmpty) {
            return const Center(
              child: Text(
                'No categories found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (_, i) {
              final category = controller.categories[i];
              return GestureDetector(
                onTap: () => controller.onCategoryTap(category),
                child: Card(
                  color: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.r),
                          ),
                          child: Image.network(
                            category.imageUrl,
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surface,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          if (controller.isVideosLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.videos.isEmpty) {
            return const Center(
              child: Text(
                'No new content found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.videos.length,
            itemBuilder: (_, i) {
              final item = controller.videos[i];
              return Card(
                color: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.only(bottom: 16.h),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12.w),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.thumbnail,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: Icon(Icons.broken_image, color: Colors.white24),
                      ),
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  subtitle: Text(
                    item.description ?? '',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => controller.onVideoTap(item),
                ),
              );
            },
          );
        }
      }),
    );
  }
}

enum SeeAllType { categories, newOnEstoriz }

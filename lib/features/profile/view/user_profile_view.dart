import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/profile/controller/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile View',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshUserData();
            await controller.fetchProfiles();
          },
          child: ListView(
            padding: EdgeInsets.all(16.w),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // User Account Details Header
              Obx(() {
                final user = controller.currentUserData.value;
                if (user == null) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.only(bottom: 24.h),
                    alignment: Alignment.center,
                    child: Text(
                      'Please log in to view account details',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 24.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.surface.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: controller.activeAvatar.value.isNotEmpty
                            ? (controller.activeAvatar.value.startsWith('assets')
                                ? AssetImage(controller.activeAvatar.value) as ImageProvider
                                : NetworkImage(controller.activeAvatar.value))
                            : (user.avatar != null && user.avatar!.isNotEmpty
                                ? NetworkImage(user.avatar!)
                                : null),
                        child: controller.activeAvatar.value.isEmpty &&
                                (user.avatar == null || user.avatar!.isEmpty)
                            ? Icon(
                                Icons.account_circle,
                                color: AppColors.primary,
                                size: 60.sp,
                              )
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        controller.activeProfileName.value.isNotEmpty
                            ? controller.activeProfileName.value
                            : (user.name ?? 'Unknown User'),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email ?? 'No Email',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      if (user.phone != null && user.phone!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user.phone!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          (user.subscriptionStatus ?? 'Free').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Section Title
              if (controller.profiles.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                  child: Text(
                    'Linked Profiles',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...controller.profiles.map((profile) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.w),
                      leading: CircleAvatar(
                        radius: 28.r,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                            ? NetworkImage(profile.avatarUrl!)
                            : null,
                        child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                            ? Icon(Icons.person, color: AppColors.primary, size: 30.sp)
                            : null,
                      ),
                      title: Text(
                        profile.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              if (profile.isKidsMode)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Kids',
                                    style: TextStyle(color: Colors.orange, fontSize: 10.sp),
                                  ),
                                ),
                              if (profile.isKidsMode) SizedBox(width: 8.w),
                              Text(
                                'Rating: ${profile.maturityRating ?? 'U'}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Lang: ${profile.language?.toUpperCase() ?? 'EN'}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        profile.isActive ? Icons.check_circle : Icons.cancel,
                        color: profile.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      }),
    );
  }
}


import 'package:estoriz/core/utils/user_data.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/dashboard/controller/dashboard_controller.dart';
import 'package:estoriz/features/home/data/models/announcement_model.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';
import 'package:estoriz/features/home/presentation/views/home_view.dart';
import 'package:estoriz/features/profile/controller/profile_selection_controller.dart';
import 'package:estoriz/features/search/controller/search_controller.dart';
import 'package:estoriz/features/livestreaming/presentation/views/livestreaming_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          if (controller.currentIndex.value != 0) {
            controller.changeTab(0);
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              _SearchPlaceholder(),
              LivestreamingView(),
              _AnnouncementPlaceholder(),
              _ProfilePlaceholder(),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  Map<String, dynamic>? _activeProfile(ProfileController profileController) {
    final activeId = profileController.activeProfileId.value;
    if (activeId == null || activeId.isEmpty) {
      return null;
    }

    for (final profile in profileController.profiles) {
      if (profile.id == activeId) {
        return {'name': profile.name, 'avatar': profile.avatar};
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Obx(() {
            final activeProfile = _activeProfile(profileController);
            final activeAvatar = activeProfile?['avatar']?.toString() ?? '';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.live_tv_rounded,
                  label: 'Live',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.campaign_rounded,
                  label: 'announce',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                  avatarPath: activeAvatar,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String avatarPath;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.avatarPath = '',
  });

  Widget _buildIcon() {
    if (avatarPath.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          avatarPath,
          width: 24.sp,
          height: 24.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            icon,
            size: 24.sp,
            color: isActive ? AppColors.primary : AppColors.textHint,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: 24.sp,
      color: isActive ? AppColors.primary : AppColors.textHint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _buildIcon(),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textHint,
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            SizedBox(height: 2.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 18.w : 0,
              height: 2.5.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<SearchController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: SearchBar(
                hintText: 'Search movies, shows...',
                hintStyle: WidgetStatePropertyAll(
                  TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                ),
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.surfaceVariant,
                ),
                elevation: const WidgetStatePropertyAll(0),
                leading: Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                  size: 22.sp,
                ),
                onChanged: (value) {
                  searchController.onQueryChanged(value);
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (searchController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        searchController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                if (!searchController.hasSearched.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 64.sp,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Search for your favourite content',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (searchController.results.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                final groupedEntries = searchController.groupedResults.entries
                    .toList(growable: false);

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = groupedEntries[index];
                    final category = entry.key;
                    final videos = entry.value;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...videos.map(
                            (video) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              minVerticalPadding: 2.h,
                              title: Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                video.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp,
                                ),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: SizedBox(
                                  width: 70.w,
                                  height: 42.h,
                                  child: video.thumbnail.isNotEmpty
                                      ? Image.network(
                                          video.thumbnail,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: AppColors.surfaceVariant,
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: AppColors.textHint,
                                                  size: 18.sp,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.textHint,
                                            size: 18.sp,
                                          ),
                                        ),
                                ),
                              ),
                              onTap: () =>
                                  Get.find<HomeController>().playVideo({
                                    'id': video.id,
                                    'title': video.title,
                                    'description': video.description,
                                    'duration': video.duration,
                                    'videoUrl': video.videoUrl,
                                  }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementPlaceholder extends GetView<HomeController> {
  const _AnnouncementPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Announcements',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Obx(
                    () =>
                        controller.isAnnouncementsLoading.value &&
                            controller.announcements.isNotEmpty
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isAnnouncementsLoading.value &&
                    controller.announcements.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.announcements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign_rounded,
                          size: 64.sp,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No announcements right now',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: controller.fetchAnnouncements,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchAnnouncements,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    itemCount: controller.announcements.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) => _AnnouncementCard(
                      item: controller.announcements[index],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementItem item;

  const _AnnouncementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.announcementDetails, arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outline),
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 92.w,
                height: 72.h,
                child: (item.imageUrl ?? '').isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _announcementFallback(),
                      )
                    : _announcementFallback(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isEmpty ? 'Announcement' : item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((item.description ?? '').isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      item.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
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

  Widget _announcementFallback() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.campaign_rounded,
        color: AppColors.textHint,
        size: 24.sp,
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  Map<String, dynamic>? _activeProfile(ProfileController profileController) {
    final activeId = profileController.activeProfileId.value;
    if (activeId == null || activeId.isEmpty) {
      return null;
    }

    for (final profile in profileController.profiles) {
      if (profile.id == activeId) {
        return {'name': profile.name, 'avatar': profile.avatar};
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final activeProfile = _activeProfile(profileController);
      final activeAvatar = activeProfile?['avatar']?.toString() ?? '';
      final activeName = activeProfile?['name']?.toString().trim() ?? '';

      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 32.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 48.r,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: activeAvatar.isNotEmpty
                    ? AssetImage(activeAvatar)
                    : null,
                child: activeAvatar.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        size: 52.sp,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              SizedBox(height: 16.h),
              Text(
                activeName.isNotEmpty
                    ? activeName
                    : (UserData().getLoginData.user?.name ?? 'User Name'),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                UserData().getLoginData.user?.email ?? 'user@example.com',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 32.h),
              _ProfileMenuItem(
                icon: Icons.workspace_premium_rounded,
                label: 'Upgrade Plan',
                textColor: AppColors.primary,
                iconColor: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.subscription),
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_rounded,
                label: 'Watchlist',
                onTap: () => Get.toNamed(AppRoutes.watchlist),
              ),
              _ProfileMenuItem(
                icon: Icons.history_rounded,
                label: 'Watch History',
                onTap: () => Get.toNamed(AppRoutes.watchHistory),
              ),
              _ProfileMenuItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
              // _ProfileMenuItem(
              //   icon: Icons.logout_rounded,
              //   label: 'Sign Out',
              //   onTap: () => showDialog<void>(
              //     context: context,
              //     builder: (dialogContext) => AlertDialog(
              //       title: const Text('Confirm Logout'),
              //       content: const Text(
              //         'Are you sure you want to logout from your account?',
              //       ),
              //       actions: [
              //         TextButton(
              //           onPressed: () => Navigator.of(dialogContext).pop(),
              //           child: const Text('Cancel'),
              //         ),
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(dialogContext).pop();
              //             UserData().removeUserData();
              //           },
              //           child: const Text('Logout'),
              //         ),
              //       ],
              //     ),
              //   ),
              //   isDestructive: true,
              // ),
            ],
          ),
        ),
      );
    });
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFE53935)
        : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 2.h),
      leading: Icon(icon, color: iconColor ?? color, size: 22.sp),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint,
        size: 20.sp,
      ),
      onTap: onTap,
    );
  }
}

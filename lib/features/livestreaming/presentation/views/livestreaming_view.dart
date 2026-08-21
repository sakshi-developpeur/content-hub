import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/live_event_model.dart';
import '../controllers/livestreaming_controller.dart';
import '../widgets/live_event_card.dart';

class LivestreamingView extends GetView<LivestreamingController> {
  const LivestreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                      'Livestreaming',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Obx(() => controller.isLoading.value
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search live classes...',
                    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint, size: 20.sp),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textHint,
                  onTap: (index) {
                    final status = index == 0 ? 'live' : (index == 1 ? 'scheduled' : 'ended');
                    controller.setStatusFilter(status);
                  },
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Live Now'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
              
              Expanded(
                child: Obx(() {
                  if (controller.liveEvents.isEmpty && controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.liveEvents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.live_tv_rounded,
                            size: 64.sp,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No events found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: () => controller.fetchLiveEvents(refresh: true),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchLiveEvents(refresh: true),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: controller.liveEvents.length,
                      itemBuilder: (context, index) {
                        final event = controller.liveEvents[index];
                        return LiveEventCard(
                          event: event,
                          onEnroll: () {
                            Get.snackbar(
                              'Enrollment',
                              'Feature coming soon for ${event.title}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          onJoin: () => controller.joinLivestream(event),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

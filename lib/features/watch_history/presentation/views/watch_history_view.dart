import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/watch_history/presentation/controllers/watch_history_controller.dart';
import 'package:estoriz/features/watch_history/presentation/views/history_video_card.dart';

class WatchHistoryScreen extends GetView<WatchHistoryController> {
  const WatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Watch History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyList.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 58.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No watch history',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchWatchHistory,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 20.h),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: HistoryVideoCard(video: item),
              );
            },
          ),
        );
      }),
    );
  }
}

class WatchHistoryView extends StatelessWidget {
  const WatchHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WatchHistoryScreen();
  }
}

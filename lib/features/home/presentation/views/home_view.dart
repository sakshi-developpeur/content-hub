import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';
import 'package:estoriz/features/home/presentation/widgets/banner_widget.dart';
import 'package:estoriz/features/home/presentation/widgets/category_section.dart';
import 'package:estoriz/features/home/presentation/widgets/recommendation_section.dart';

class HomeView extends BasePage<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: controller.retryAll,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _HomeAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full-screen banner carousel
                  const BannerWidget(),
                  SizedBox(height: 28.h),

                  // Popular Now â€” portrait cards
                  const CategorySection(),
                  SizedBox(height: 28.h),

                  // New on OTT â€” landscape cards
                  const NewOnOttSection(),
                  SizedBox(height: 28.h),

                  // Recommendations â€” curated cards
                  const RecommendationSection(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: kToolbarHeight,
      title: Image.asset(
        'assets/images/app_logo.png',
        height: 32.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

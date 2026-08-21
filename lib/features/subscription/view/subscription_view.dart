import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:estoriz/common/app_button.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/subscription/controller/subscription_controller.dart';
import 'package:estoriz/features/subscription/data/models/subscription_plan_model.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF09021D), Color(0xFF130736), Color(0xFF1B0A4A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final visiblePlans = controller.visiblePlans;
            return RefreshIndicator(
              onRefresh: controller.fetchPlans,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SubscriptionHeader(),
                          SizedBox(height: 20.h),
                          _HeroBanner(),
                          SizedBox(height: 22.h),
                          _DurationSelector(),
                          SizedBox(height: 22.h),
                          if (controller.isLoading.value)
                            const _PlanSkeletonList()
                          else if (controller.errorMessage.value.isNotEmpty)
                            _ErrorState(message: controller.errorMessage.value)
                          else if (visiblePlans.isEmpty)
                            _EmptyPlansState(
                              durationLabel: controller.durationLabel(
                                controller.selectedDuration.value,
                              ),
                            )
                          else
                            _PlansList(plans: visiblePlans),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SubscriptionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
          ),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Premium plans for the best experience',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA93A), Color(0xFFFE6A3A), Color(0xFF8C3BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              'ESTORIZ PREMIUM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Watch without limits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ad-free access, more devices, and early access to the best content.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              _BenefitChip(icon: Icons.tv_rounded, label: 'Multi-device'),
              _BenefitChip(icon: Icons.block_rounded, label: 'Ad-free'),
              _BenefitChip(icon: Icons.flash_on_rounded, label: 'Early access'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends GetView<SubscriptionController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final durations = controller.availableDurations;

      return Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: durations
              .map((duration) {
                final selected = controller.selectedDuration.value == duration;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeDuration(duration),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999.r),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFFFB53F), Color(0xFFFF6A3D)],
                              )
                            : null,
                        color: selected ? null : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.durationLabel(duration),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (duration == 'yearly') ...[
                            SizedBox(height: 2.h),
                            Text(
                              'Best value',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      );
    });
  }
}

class _PlansList extends GetView<SubscriptionController> {
  final List<SubscriptionPlan> plans;

  const _PlansList({required this.plans});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: plans
          .map((plan) {
            final code = plan.code.toLowerCase();
            final isHighlighted = code == 'diamond' || code == 'premium';
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _PlanCard(plan: plan, isHighlighted: isHighlighted),
            );
          })
          .toList(growable: false),
    );
  }
}

class _PlanCard extends GetView<SubscriptionController> {
  final SubscriptionPlan plan;
  final bool isHighlighted;

  const _PlanCard({required this.plan, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    final selectedPrice = plan.priceFor(controller.selectedDuration.value);
    final isFree = plan.isFree;
    final isCurrentPlan = controller.isCurrentPlan(plan);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: isHighlighted
              ? const [Color(0xFF2B175D), Color(0xFF4A2592), Color(0xFF0E0829)]
              : const [Color(0xFF171031), Color(0xFF24164A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFFFB13C) : AppColors.outline,
          width: isHighlighted ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plan.code.toLowerCase() == 'premium')
                      Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB13C),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'MOST PREMIUM',
                          style: TextStyle(
                            color: const Color(0xFF2E1700),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    if (plan.isReachedLimit)
                      Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    Text(
                      plan.displayName,
                      style: TextStyle(
                        color: plan.isReachedLimit
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.subtitleFor(plan),
                      style: TextStyle(
                        color: plan.isReachedLimit
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.formatPrice((selectedPrice)),
                      style: TextStyle(
                        color: plan.isReachedLimit
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isFree
                          ? 'Starter access'
                          : 'per ${controller.durationLabel(controller.selectedDuration.value).toLowerCase()}',
                      style: TextStyle(
                        color: plan.isReachedLimit
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller
              .featureBullets(plan)
              .take(4)
              .map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2.h),
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: plan.isReachedLimit
                              ? Colors.white.withOpacity(0.04)
                              : (isHighlighted
                                    ? const Color(0x26FFB13C)
                                    : Colors.white.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: plan.isReachedLimit
                              ? Colors.white.withOpacity(0.2)
                              : (isHighlighted
                                    ? const Color(0xFFFFB13C)
                                    : AppColors.primaryLight),
                          size: 14.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: plan.isReachedLimit
                                ? Colors.white.withOpacity(0.4)
                                : Colors.white.withValues(alpha: 0.92),
                            fontSize: 12.sp,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: 8.h),
          Obx(() {
            final isProcessing = controller.isProcessingPlan(plan);
            return AppButton.primary(
              text: isCurrentPlan
                  ? 'Current Plan'
                  : plan.isReachedLimit
                  ? 'Sold Out'
                  : isFree
                  ? 'Start Watching'
                  : isProcessing
                  ? 'Processing...'
                  : 'Buy Now',
              onPressed: isCurrentPlan || plan.isReachedLimit
                  ? null
                  : isFree
                  ? () {}
                  : isProcessing
                  ? null
                  : () => controller.initiatePayment(plan),
              width: double.infinity,
              backgroundColor: plan.isReachedLimit
                  ? Colors.grey.withOpacity(0.3)
                  : null,
            );
          }),
        ],
      ),
    );
  }
}

class _PlanSkeletonList extends StatelessWidget {
  const _PlanSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          width: double.infinity,
          height: 250.h,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends GetView<SubscriptionController> {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: AppColors.textSecondary,
            size: 34.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Unable to load subscription plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          AppButton.primary(
            text: 'Try Again',
            onPressed: controller.fetchPlans,
          ),
        ],
      ),
    );
  }
}

class _EmptyPlansState extends StatelessWidget {
  final String durationLabel;

  const _EmptyPlansState({required this.durationLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.subscriptions_rounded,
            color: AppColors.textSecondary,
            size: 34.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'No $durationLabel plans available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Choose another billing duration to see available plans.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

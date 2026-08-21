import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/settings/controller/settings_controller.dart';
import 'package:estoriz/features/settings/model/support_ticket_model.dart';

class ContactUsView extends GetView<SettingsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isTicketsLoading.value && controller.tickets.isEmpty) {
        controller.fetchTickets();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreateTicketPage,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          _StatusFilters(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isTicketsLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.tickets.isEmpty) {
                return Center(
                  child: Text(
                    'No tickets found',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchTickets,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                  itemCount: controller.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = controller.tickets[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _TicketCard(ticket: ticket),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    const filters = ['all', 'open', 'in-progress', 'resolved', 'closed'];

    return SizedBox(
      height: 38.h,
      child: Obx(() {
        final selectedStatus = controller.selectedTicketStatus.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: filters.length,
          separatorBuilder: (context, index) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final value = filters[index];
            final selected =
                (selectedStatus.isEmpty && value == 'all') ||
                selectedStatus == value;

            return ChoiceChip(
              label: Text(value),
              selected: selected,
              onSelected: (_) => controller.applyTicketStatusFilter(value),
              selectedColor: AppColors.primary.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.surface,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              _Badge(label: ticket.status, color: _statusColor(ticket.status)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            ticket.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _Badge(
                label: 'Priority: ${ticket.priority}',
                color: _priorityColor(ticket.priority),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(ticket.updatedAt),
                style: TextStyle(color: AppColors.textHint, fontSize: 10.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _RepliesSection(replies: ticket.replies),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: ticket.id.isEmpty
                  ? null
                  : () => _showReplyDialog(context, controller),
              icon: const Icon(Icons.reply_rounded, size: 16),
              label: const Text('Reply'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReplyDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final inputController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Reply to Ticket',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
          ),
          content: TextField(
            controller: inputController,
            maxLines: 4,
            minLines: 3,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              hintStyle: TextStyle(color: AppColors.textHint),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            Obx(() {
              return FilledButton(
                onPressed: controller.isSubmittingReply.value
                    ? null
                    : () => controller.submitTicketReply(
                        ticketId: ticket.id,
                        message: inputController.text,
                      ),
                child: controller.isSubmittingReply.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              );
            }),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF22C55E);
      case 'closed':
        return const Color(0xFF64748B);
      case 'in-progress':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }
}

class _RepliesSection extends StatelessWidget {
  const _RepliesSection({required this.replies});

  final List<SupportTicketReply> replies;

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return Text(
        'No replies yet',
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 11.sp,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Replies',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        ...replies.map(
          (reply) => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reply.sender.isEmpty ? 'Support' : reply.sender,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(reply.createdAt),
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  reply.message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

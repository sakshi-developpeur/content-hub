import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:estoriz/core/utils/app_colors.dart';

class LiveChatSection extends StatefulWidget {
  const LiveChatSection({super.key});

  @override
  State<LiveChatSection> createState() => _LiveChatSectionState();
}

class _LiveChatSectionState extends State<LiveChatSection> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'user': 'Teacher', 'message': 'Welcome to the live class! Feel free to ask any questions.'},
    {'user': 'Adil', 'message': 'Hello sir! Can you explain the patterns again?'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'user': 'You',
        'message': _messageController.text.trim(),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Chat & Doubts',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(12.w),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['user'] == 'You';
                    final isTeacher = msg['user'] == 'Teacher';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['user']!,
                            style: TextStyle(
                              color: isTeacher ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              msg['message']!,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: AppColors.outline),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Ask a doubt...',
                          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.sp),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send_rounded, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

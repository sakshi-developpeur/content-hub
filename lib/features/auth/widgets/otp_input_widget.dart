import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/value/dimension.dart';

/// OTP Input Widget - digit code input boxes
class OtpInputWidget extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;

  const OtpInputWidget({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<FocusNode> _listenerFocusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _listenerFocusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in _listenerFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.isEmpty) {
      widget.onChanged?.call(_otp);
      return;
    }

    if (value.length > 1) {
      _handlePaste(index, value);
      return;
    }

    if (value.length == 1) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Only unfocus if it's the last field and we want to close keyboard
        // However, usually we keep it open for a moment or until build finishes
        // _focusNodes[index].unfocus();
      }
    }

    widget.onChanged?.call(_otp);

    // Check if OTP is complete
    if (_otp.length == widget.length) {
      widget.onCompleted(_otp);
    }
  }

  void _handlePaste(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return;
    }

    // If user pasted a full OTP, always fill from the first box.
    final startIndex = digitsOnly.length >= widget.length ? 0 : index;
    final maxInsert = widget.length - startIndex;
    final chars = digitsOnly.split('').take(maxInsert).toList();

    for (int i = 0; i < maxInsert; i++) {
      _controllers[startIndex + i].text = i < chars.length ? chars[i] : '';
    }

    final isComplete = _otp.length == widget.length;
    if (isComplete) {
      _focusNodes[widget.length - 1].unfocus();
    } else {
      final nextIndex = startIndex + chars.length;
      if (nextIndex < widget.length) {
        _focusNodes[nextIndex].requestFocus();
      }
    }

    widget.onChanged?.call(_otp);
    if (isComplete) {
      widget.onCompleted(_otp);
    }
  }

  void _onKeyPress(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: KeyboardListener(
            focusNode: _listenerFocusNodes[index],
            onKeyEvent: (event) => _onKeyPress(index, event),
            child: SizedBox(
              width: 44.w,
              height: 52.h,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.all(12),
                    borderSide: BorderSide(
                      color: AppColors.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.all(12),
                    borderSide: BorderSide(
                      color: AppColors.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.all(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}

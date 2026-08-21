import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';

/// Reusable Text Field Widgets for OTT App
///
/// Usage:
/// ```dart
/// AppTextField(controller: _controller, hint: "Enter email", label: "Email")
/// AppTextField.password(controller: _passController, label: "Password")
/// AppTextField.search(controller: _searchController, onChanged: (v) {})
/// ```
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final _TextFieldType _type;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField._({
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    required _TextFieldType type,
    this.inputFormatters,
  }) : _type = type;

  /// Standard text field
  factory AppTextField({
    TextEditingController? controller,
    String? hint,
    String? label,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    bool enabled = true,
    bool readOnly = false,
    int maxLines = 1,
    int? maxLength,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return AppTextField._(
      controller: controller,
      hint: hint,
      label: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      autofocus: autofocus,
      type: _TextFieldType.standard,
    );
  }

  /// Password text field with visibility toggle
  factory AppTextField.password({
    TextEditingController? controller,
    String? hint,
    String? label,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputAction textInputAction = TextInputAction.done,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return AppTextField._(
      controller: controller,
      hint: hint ?? 'Enter password',
      label: label ?? 'Password',
      prefixIcon: Icons.lock_outline,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      type: _TextFieldType.password,
    );
  }

  /// Search text field with search icon
  factory AppTextField.search({
    TextEditingController? controller,
    String? hint,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    VoidCallback? onClear,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return AppTextField._(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      type: _TextFieldType.search,
    );
  }

  /// Email text field
  factory AppTextField.email({
    TextEditingController? controller,
    String? hint,
    String? label,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return AppTextField._(
      controller: controller,
      hint: hint ?? 'Enter email',
      label: label ?? 'Email',
      prefixIcon: Icons.email_outlined,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      type: _TextFieldType.standard,
    );
  }

  /// Phone text field
  factory AppTextField.phone({
    TextEditingController? controller,
    String? hint,
    String? label,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return AppTextField._(
      controller: controller,
      hint: hint ?? 'Enter phone number',
      label: label ?? 'Phone',
      prefixIcon: Icons.phone_outlined,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      inputFormatters: [LengthLimitingTextInputFormatter(10)],
      type: _TextFieldType.standard,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (val) {
        FocusScope.of(context).unfocus();
      },
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      obscureText: widget._type == _TextFieldType.password
          ? _obscureText
          : false,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: 20.w,
                color: AppColors.textSecondary,
              )
            : null,
        suffixIcon: _buildSuffixIcon(),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppPaddings.symmetric(h: 16, v: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(color: AppColors.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.all(12),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.38),
            width: 1,
          ),
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textHint,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          fontSize: 12.sp,
          color: AppColors.error,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        errorMaxLines: 2,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget._type == _TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.w,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget._type == _TextFieldType.search && widget.controller != null) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.controller!,
        builder: (context, value, child) {
          if (value.text.isNotEmpty) {
            return IconButton(
              icon: Icon(
                Icons.clear,
                size: 20.w,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                widget.controller!.clear();
                widget.onChanged?.call('');
              },
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    return widget.suffixIcon;
  }
}

enum _TextFieldType { standard, password, search }

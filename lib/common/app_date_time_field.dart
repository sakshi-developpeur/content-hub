import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../core/utils/app_colors.dart';
import '../core/value/dimension.dart';

/// Date/Time Field Widget for OTT App
///
/// Usage:
/// ```dart
/// AppDateTimeField.date(label: "Birth Date", onChanged: (date) {})
/// AppDateTimeField.time(label: "Start Time", onChanged: (time) {})
/// AppDateTimeField.dateTime(label: "Event Date & Time", onChanged: (dateTime) {})
/// ```
class AppDateTimeField extends StatefulWidget {
  final String? label;
  final String? hint;
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime?)? onChanged;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final _DateTimeType _type;
  final String? dateFormat;
  final String? timeFormat;

  const AppDateTimeField._({
    this.label,
    this.hint,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
    this.enabled = true,
    required _DateTimeType type,
    this.dateFormat,
    this.timeFormat,
  }) : _type = type;

  /// Date only picker
  factory AppDateTimeField.date({
    String? label,
    String? hint,
    DateTime? initialValue,
    DateTime? firstDate,
    DateTime? lastDate,
    void Function(DateTime?)? onChanged,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    String dateFormat = 'dd MMM yyyy',
  }) {
    return AppDateTimeField._(
      label: label ?? 'Select Date',
      hint: hint ?? 'Pick a date',
      initialValue: initialValue,
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      type: _DateTimeType.date,
      dateFormat: dateFormat,
    );
  }

  /// Time only picker
  factory AppDateTimeField.time({
    String? label,
    String? hint,
    DateTime? initialValue,
    void Function(DateTime?)? onChanged,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    String timeFormat = 'hh:mm a',
  }) {
    return AppDateTimeField._(
      label: label ?? 'Select Time',
      hint: hint ?? 'Pick a time',
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      type: _DateTimeType.time,
      timeFormat: timeFormat,
    );
  }

  /// Date and Time picker
  factory AppDateTimeField.dateTime({
    String? label,
    String? hint,
    DateTime? initialValue,
    DateTime? firstDate,
    DateTime? lastDate,
    void Function(DateTime?)? onChanged,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    String dateFormat = 'dd MMM yyyy',
    String timeFormat = 'hh:mm a',
  }) {
    return AppDateTimeField._(
      label: label ?? 'Select Date & Time',
      hint: hint ?? 'Pick date and time',
      initialValue: initialValue,
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      type: _DateTimeType.dateTime,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );
  }

  @override
  State<AppDateTimeField> createState() => _AppDateTimeFieldState();
}

class _AppDateTimeFieldState extends State<AppDateTimeField> {
  late TextEditingController _controller;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialValue;
    _controller = TextEditingController(
      text: _formatDateTime(_selectedDateTime),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    switch (widget._type) {
      case _DateTimeType.date:
        return DateFormat(widget.dateFormat ?? 'dd MMM yyyy').format(dateTime);
      case _DateTimeType.time:
        return DateFormat(widget.timeFormat ?? 'hh:mm a').format(dateTime);
      case _DateTimeType.dateTime:
        return '${DateFormat(widget.dateFormat ?? 'dd MMM yyyy').format(dateTime)} ${DateFormat(widget.timeFormat ?? 'hh:mm a').format(dateTime)}';
    }
  }

  Future<void> _showPicker() async {
    if (!widget.enabled) return;

    DateTime? result;

    switch (widget._type) {
      case _DateTimeType.date:
        result = await _showDatePicker();
      case _DateTimeType.time:
        result = await _showTimePicker();
      case _DateTimeType.dateTime:
        result = await _showDateTimePicker();
    }

    if (result != null) {
      setState(() {
        _selectedDateTime = result;
        _controller.text = _formatDateTime(result);
      });
      widget.onChanged?.call(result);
    }
  }

  Future<DateTime?> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) => _buildPickerTheme(child),
    );
    return date;
  }

  Future<DateTime?> _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      builder: (context, child) => _buildPickerTheme(child),
    );

    if (time != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    return null;
  }

  Future<DateTime?> _showDateTimePicker() async {
    // First pick date
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) => _buildPickerTheme(child),
    );

    if (date == null) return null;

    // Then pick time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      builder: (context, child) => _buildPickerTheme(child),
    );

    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    return date;
  }

  Widget _buildPickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  IconData get _suffixIcon {
    switch (widget._type) {
      case _DateTimeType.date:
        return Icons.calendar_today_outlined;
      case _DateTimeType.time:
        return Icons.access_time_outlined;
      case _DateTimeType.dateTime:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: _selectedDateTime,
      validator: widget.validator != null
          ? (value) => widget.validator!(value)
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showPicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _controller,
                  enabled: widget.enabled,
                  readOnly: true,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    labelText: widget.label,
                    suffixIcon: Icon(
                      _suffixIcon,
                      size: 20.w,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: AppPaddings.symmetric(h: 16, v: 16),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.all(12),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.all(12),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.all(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: AppRadius.all(12),
                      borderSide: BorderSide(color: AppColors.error, width: 1),
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
                    errorText: state.hasError ? state.errorText : null,
                    errorStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _DateTimeType { date, time, dateTime }


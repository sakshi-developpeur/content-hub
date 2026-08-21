import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:toastification/toastification.dart';

mixin ApiHelperMixin {
  final RxBool _isLoading = false.obs;

  void setLoadingState(bool loading) {
    _isLoading.value = loading;
  }

  RxBool get isLoading => _isLoading;

  void showErrorMessage({String? title, required String message}) {
    String displayMessage = message;

    Toastification().show(
      title: Text(
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        displayMessage,
        style: TextStyle(color: Colors.white),
      ),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      showIcon: false,
      backgroundColor: AppColors.error,
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onPressed) => IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }

  void showSuccessMessage({String? title, required String message}) {
    String displayMessage = message;

    Toastification().show(
      title: Text(
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        displayMessage,
        style: TextStyle(color: Colors.white),
      ),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      showIcon: false,
      backgroundColor: AppColors.success,
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onPressed) => IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }

  void showInfoMessage({String? title, required String message}) {
    String displayMessage = message;

    Toastification().show(
      title: Text(
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        displayMessage,
        style: TextStyle(color: Colors.white),
      ),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 3),
      showIcon: false,
      backgroundColor: AppColors.info,
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onPressed) => IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }

  void showWarningMessage({String? title, required String message}) {
    String displayMessage = message;

    Toastification().show(
      title: Text(
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        displayMessage,
        style: TextStyle(color: Colors.white),
      ),
      type: ToastificationType.warning,
      autoCloseDuration: const Duration(seconds: 3),
      showIcon: false,
      backgroundColor: AppColors.warning,
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onPressed) => IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }
}


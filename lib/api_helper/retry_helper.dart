import 'package:flutter/material.dart';
import 'package:estoriz/api_helper/exception.dart';

// Mixin to easily use in any Controller or View
mixin ApiRetryHelper {
  Future<void> makeApiCallWithRetry({
    required BuildContext context,
    required Future<void> Function() apiCall,
  }) async {
    try {
      await apiCall();
    } catch (e) {
      // If error is network related or 500, show Retry Dialog
      if (e is ApiException && _isNetworkError(e)) {
        if (context.mounted) {
          _showRetryDialog(context, apiCall);
        }
      } else {
        // Show standard error snackbar for other errors (e.g., 400 Bad Request)
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  bool _isNetworkError(ApiException error) {
    return error.isNetworkError;
  }

  void _showRetryDialog(BuildContext context, Future<void> Function() onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Connection Failed"),
        content: const Text(
          "We couldn't reach the server. Please check your internet connection.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              makeApiCallWithRetry(
                context: context,
                apiCall: onRetry,
              ); // RECURSIVE RETRY
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

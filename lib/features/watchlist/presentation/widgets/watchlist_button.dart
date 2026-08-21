import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';
import 'package:estoriz/features/watchlist/presentation/controllers/watchlist_controller.dart';

class WatchlistButton extends StatelessWidget {
  const WatchlistButton({
    super.key,
    required this.video,
    this.allowRemoveOnToggle,
    this.iconSize,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.showLabel = false,
  });

  final VideoModel video;
  final bool? allowRemoveOnToggle;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatchlistController>();

    return Obx(() {
      final saved = controller.isInWatchlist(video.id);

      return Material(
        color: backgroundColor ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor ?? Colors.white24),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final added = await controller.toggleWatchlist(
              video,
              allowRemove: allowRemoveOnToggle,
            );

            final nowSaved = controller.isInWatchlist(video.id);
            final message = added
                ? 'Added to watchlist'
                : (nowSaved
                      ? 'Already in watchlist'
                      : 'Removed from watchlist');

            Get.snackbar(
              'Watchlist',
              message,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  saved ? Icons.check : Icons.add,
                  color: saved ? Colors.green : Colors.white,
                  size: iconSize ?? 20,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Watchlist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

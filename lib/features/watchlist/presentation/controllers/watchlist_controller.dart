import 'package:get/get.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';
import 'package:estoriz/features/watchlist/data/services/local_storage_service.dart';

class WatchlistController extends GetxController {
  WatchlistController({
    LocalStorageService? localStorageService,
    this.allowRemoveOnToggle = true,
  }) : _localStorageService = localStorageService ?? LocalStorageService();

  final LocalStorageService _localStorageService;
  final WatchHistoryRepository _watchHistoryRepository =
      WatchHistoryRepository();
  final bool allowRemoveOnToggle;

  // Reactive watchlist collection used by Obx widgets.
  final RxList<VideoModel> watchlist = <VideoModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    isLoading.value = true;
    final items = await _localStorageService.loadWatchlist();
    final history = await _watchHistoryRepository.fetchWatchHistory();
    watchlist.assignAll(_mergeWatchHistory(items, history));
    isLoading.value = false;
  }

  List<VideoModel> _mergeWatchHistory(
    List<VideoModel> items,
    List<WatchHistoryModel> history,
  ) {
    final historyById = <String, WatchHistoryModel>{
      for (final item in history) item.videoId: item,
    };

    return items
        .map((video) {
          final match = historyById[video.id];
          if (match == null) {
            return video;
          }

          return video.copyWith(
            title: video.title.isEmpty ? match.title : video.title,
            thumbnail: video.thumbnail.isEmpty
                ? match.thumbnail
                : video.thumbnail,
            videoUrl: video.videoUrl.isEmpty ? match.videoUrl : video.videoUrl,
            watchedPosition: match.watchedPosition,
            totalDuration: match.totalDuration,
          );
        })
        .toList(growable: false);
  }

  Future<void> openWatchlistVideo(VideoModel video) async {
    var playable = video;
    if (video.videoUrl.trim().isEmpty || video.watchedPosition > 0) {
      final historyItem = WatchHistoryModel(
        videoId: video.id,
        title: video.title,
        thumbnail: video.thumbnail,
        videoUrl: video.videoUrl,
        totalDuration: video.totalDuration,
        watchedPosition: video.watchedPosition,
        lastWatched: DateTime.now(),
      );
      final enriched = await _watchHistoryRepository.ensurePlayableData(
        historyItem,
      );
      playable = video.copyWith(
        title: enriched.title,
        thumbnail: enriched.thumbnail,
        videoUrl: enriched.videoUrl,
        watchedPosition: enriched.watchedPosition,
        totalDuration: enriched.totalDuration,
      );
    }

    Get.toNamed(
      AppRoutes.videoPlayer,
      arguments: {
        'id': playable.id,
        'title': playable.title,
        'thumbnail': playable.thumbnail,
        'videoUrl': playable.videoUrl,
        'watchedPosition': playable.watchedPosition,
        'lastPositionSeconds': playable.watchedPosition,
      },
    );
  }

  Future<void> saveWatchlist() async {
    await _localStorageService.saveWatchlist(watchlist);
  }

  bool isInWatchlist(String videoId) {
    return watchlist.any((video) => video.id == videoId);
  }

  Future<bool> toggleWatchlist(VideoModel video, {bool? allowRemove}) async {
    if (video.id.isEmpty) {
      return false;
    }

    final removeIfExists = allowRemove ?? allowRemoveOnToggle;
    final existingIndex = watchlist.indexWhere((item) => item.id == video.id);

    if (existingIndex >= 0) {
      if (!removeIfExists) {
        return false;
      }
      watchlist.removeAt(existingIndex);
      await saveWatchlist();
      return false;
    }

    watchlist.insert(0, video);
    await saveWatchlist();
    return true;
  }

  Future<bool> removeFromWatchlist(String videoId) async {
    final before = watchlist.length;
    watchlist.removeWhere((item) => item.id == videoId);
    if (watchlist.length != before) {
      await saveWatchlist();
      return true;
    }
    return false;
  }

  Future<bool> addToWatchlist(VideoModel video) async {
    if (isInWatchlist(video.id)) {
      return false;
    }

    watchlist.insert(0, video);
    await saveWatchlist();
    return true;
  }

  // Backward-compatible helper methods for existing screens.
  bool isVideoInWatchlist(String videoId) => isInWatchlist(videoId);

  Future<bool> addToWatchlistById(
    String videoId, {
    String title = 'Untitled',
    String thumbnail = '',
    String videoUrl = '',
  }) {
    return addToWatchlist(
      VideoModel(
        id: videoId,
        title: title,
        thumbnail: thumbnail,
        videoUrl: videoUrl,
      ),
    );
  }
}

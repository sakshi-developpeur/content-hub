import 'package:get/get.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';

class WatchHistoryController extends GetxController {
  WatchHistoryController({WatchHistoryRepository? repository})
    : _repository = repository ?? WatchHistoryRepository();

  final WatchHistoryRepository _repository;

  final RxList<WatchHistoryModel> historyList = <WatchHistoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWatchHistory();
  }

  Future<void> fetchWatchHistory() async {
    isLoading.value = true;
    final items = await _repository.fetchWatchHistory();
    historyList.assignAll(_sortByLastWatched(items));
    isLoading.value = false;
  }

  Future<void> addOrUpdateHistory(WatchHistoryModel video) async {
    if (video.videoId.isEmpty) return;

    await _repository.addOrUpdateHistory(video);

    final index = historyList.indexWhere(
      (item) => item.videoId == video.videoId,
    );
    if (index >= 0) {
      historyList[index] = video;
    } else {
      historyList.add(video);
    }

    historyList.assignAll(_sortByLastWatched(historyList));
  }

  Future<WatchHistoryModel> prepareForPlayback(WatchHistoryModel video) async {
    final enriched = await _repository.ensurePlayableData(video);
    if (enriched.videoUrl.trim().isNotEmpty) {
      await addOrUpdateHistory(enriched);
    }
    return enriched;
  }

  double getProgress(WatchHistoryModel video) {
    if (video.totalDuration <= 0) return 0;
    final value = video.watchedPosition / video.totalDuration;
    return value.clamp(0.0, 1.0);
  }

  List<WatchHistoryModel> _sortByLastWatched(List<WatchHistoryModel> list) {
    final sorted = List<WatchHistoryModel>.from(list);
    sorted.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    return sorted;
  }
}

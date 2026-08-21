import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:estoriz/features/home/data/models/video_model.dart';
import 'package:estoriz/features/search/data/services/search_service.dart';

class SearchController extends GetxController {
  SearchController(this._searchService);

  final SearchService _searchService;

  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<VideoItem> results = <VideoItem>[].obs;
  final RxMap<String, List<VideoItem>> groupedResults =
      <String, List<VideoItem>>{}.obs;

  Timer? _debounce;
  CancelToken? _cancelToken;
  int _requestId = 0;

  void onQueryChanged(String value) {
    final normalized = value.trim();
    query.value = normalized;
    _debounce?.cancel();

    if (normalized.isEmpty) {
      _cancelActiveRequest();
      hasSearched.value = false;
      isLoading.value = false;
      errorMessage.value = '';
      results.clear();
      groupedResults.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      search(normalized);
    });
  }

  Future<void> search(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return;
    }

    final requestId = ++_requestId;
    _cancelActiveRequest();
    _cancelToken = CancelToken();

    hasSearched.value = true;
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _searchService.searchVideos(
      normalized,
      limit: 20,
      cancelToken: _cancelToken,
    );

    if (requestId != _requestId) {
      return;
    }

    isLoading.value = false;

    if (!result.isSuccess) {
      if (result.message == 'cancelled') {
        return;
      }
      results.clear();
      groupedResults.clear();
      errorMessage.value = result.message ?? 'Failed to search videos';
      return;
    }

    final videos = result.data ?? const <VideoItem>[];
    results.assignAll(videos);
    groupedResults.assignAll(_groupByCategory(videos));
  }

  Map<String, List<VideoItem>> _groupByCategory(List<VideoItem> videos) {
    final grouped = <String, List<VideoItem>>{};
    for (final video in videos) {
      final key = (video.category == null || video.category!.trim().isEmpty)
          ? 'Other'
          : video.category!.trim();
      grouped.putIfAbsent(key, () => <VideoItem>[]).add(video);
    }
    return grouped;
  }

  void _cancelActiveRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _cancelActiveRequest();
    super.onClose();
  }
}

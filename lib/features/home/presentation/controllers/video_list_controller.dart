import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/features/home/data/models/video_list_model.dart';
import 'package:estoriz/features/home/data/repositories/home_repository.dart';

class VideoListController extends BaseController {
  final HomeRepository _repository;

  VideoListController(this._repository);

  final videos = RxList<VideoItem>();
  final isLoading = RxBool(false);
  final errorMessage = RxString('');
  final currentPage = RxInt(1);
  final totalPages = RxInt(1);

  String get categoryId =>
      (Get.arguments?['categoryId']?.toString() ?? '').trim();

  @override
  void onInit() {
    super.onInit();
    fetchVideosByCategory();
  }

  Future<void> fetchVideosByCategory() async {
    if (categoryId.isEmpty) {
      errorMessage.value = 'Invalid category ID';
      if (kDebugMode) print('Category ID is empty');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kDebugMode) print('Fetching videos for category: $categoryId');

      final result = await _repository.getVideosByCategory(categoryId);

      if (kDebugMode) {
        print('ðŸ“¡ API Response - Success: ${result.isSuccess}');
        print('ðŸ“¡ API Response - Data: ${result.data}');
        print('ðŸ“¡ API Response - Message: ${result.message}');
      }

      if (result.isSuccess && result.data != null) {
        videos.value = result.data!.videos;
        totalPages.value = result.data!.totalPages ?? 1;
        currentPage.value = result.data!.currentPage ?? 1;

        if (kDebugMode) {
          print('Videos loaded: ${videos.length} videos');
        }
      } else {
        errorMessage.value =
            result.message ?? 'Failed to load videos for this category';
        if (kDebugMode) {
          print('Error: ${errorMessage.value}');
        }
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('Exception: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (currentPage.value >= totalPages.value) return;
    currentPage.value++;
    await fetchVideosByCategory();
  }
}


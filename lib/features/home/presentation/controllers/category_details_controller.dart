import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/features/home/data/models/category_details_model.dart';
import 'package:estoriz/features/home/data/models/video_list_model.dart';
import 'package:estoriz/features/home/data/repositories/home_repository.dart';

class CategoryDetailsController extends BaseController {
  static const String _alphabetsParentCategoryId = '699993e9fa42530327858a36';
  static const Set<String> _alphabetCategoryIds = {
    '699993e9fa42530327858a36', // Alphabets parent
    '699993e9fa42530327858a3d', // A
    '699993e9fa42530327858a40', // B
    '699993e9fa42530327858a43', // C
    '69c509055fc2e3609e344526', // D
  };

  final HomeRepository _repository = Get.find<HomeRepository>();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CategoryDetailsItem> category = Rxn<CategoryDetailsItem>();

  final RxList<VideoItem> categoryVideos = <VideoItem>[].obs;
  final RxBool isVideosLoading = false.obs;
  final RxString videosErrorMessage = ''.obs;

  String get categoryId =>
      (Get.arguments?['categoryId']?.toString() ?? '').trim();

  @override
  void onInit() {
    super.onInit();
    fetchCategoryDetails();
  }

  Future<void> fetchCategoryDetails() async {
    if (categoryId.isEmpty) {
      errorMessage.value = 'Category id is missing';
      isLoading.value = false;
      return;
    }

    final categoryIdToFetch = _alphabetCategoryIds.contains(categoryId)
        ? _alphabetsParentCategoryId
        : categoryId;

    isLoading.value = true;
    errorMessage.value = '';

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getCategoryDetails(categoryIdToFetch);
        if (result.isSuccess && result.data != null) {
          category.value = result.data!;
        } else {
          errorMessage.value =
              result.message ?? 'Failed to load category details';
        }
      },
    );

    isLoading.value = false;
  }

  Future<void> fetchCategoryVideos(String categoryId) async {
    if (categoryId.isEmpty) {
      videosErrorMessage.value = 'Category ID is missing';
      return;
    }

    isVideosLoading.value = true;
    videosErrorMessage.value = '';

    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getVideosByCategory(categoryId);
        if (result.isSuccess && result.data != null) {
          categoryVideos.assignAll(result.data!.videos);
          print(
            ' Fetched ${result.data!.videos.length} videos for category $categoryId',
          );
          for (var video in result.data!.videos) {
            print(
              '   ${video.title} | THUMB: ${video.thumbnail} | URL: ${video.videoUrl ?? "NO_URL"} | PlaybackId: ${video.muxPlaybackId ?? "NONE"}',
            );
          }
        } else {
          videosErrorMessage.value = result.message ?? 'Failed to load videos';
          print(' Error fetching videos: ${result.message}');
        }
      },
    );

    isVideosLoading.value = false;
  }
}


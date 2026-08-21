import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/auth/widgets/login_required_bottom_sheet.dart';
import 'package:estoriz/features/home/data/models/announcement_model.dart';
import 'package:estoriz/features/home/data/models/banner_model.dart';
import 'package:estoriz/features/home/data/models/category_model.dart';
import 'package:estoriz/features/home/data/models/recommendation_model.dart';
import 'package:estoriz/features/home/data/models/video_model.dart';
import 'package:estoriz/features/home/data/repositories/home_repository.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';

class HomeController extends BaseController {
  final HomeRepository _repository = Get.find<HomeRepository>();
  final UserData _userData = UserData();
  final WatchHistoryRepository _watchHistoryRepository =
      WatchHistoryRepository();

  final PageController pageController = PageController();

  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<CategoryItem> categories = <CategoryItem>[].obs;
  final RxList<VideoItem> videos = <VideoItem>[].obs;
  final RxList<RecommendationItem> recommendations = <RecommendationItem>[].obs;
  final RxList<AnnouncementItem> announcements = <AnnouncementItem>[].obs;
  final RxBool isBannerLoading = true.obs;
  final RxBool isCategoriesLoading = true.obs;
  final RxBool isVideosLoading = true.obs;
  final RxBool isRecommendationsLoading = true.obs;
  final RxBool isAnnouncementsLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentBannerIndex = 0.obs;
  final RxMap<String, WatchHistoryModel> watchHistoryById =
      <String, WatchHistoryModel>{}.obs;

  Timer? _autoScrollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchCategories();
    fetchVideos();
    fetchRecommendations();
    fetchAnnouncements();
    fetchWatchProgress();
  }

  Future<void> fetchWatchProgress() async {
    final history = await _watchHistoryRepository.fetchWatchHistory();
    watchHistoryById.assignAll({
      for (final item in history) item.videoId: item,
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (banners.isEmpty) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!pageController.hasClients || banners.isEmpty) return;
      final next = (currentBannerIndex.value + 1) % banners.length;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> fetchBanners() async {
    isBannerLoading.value = true;
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getBanners();
        if (result.isSuccess && result.data != null) {
          banners.assignAll(result.data!);
          _startAutoScroll();
        } else {
          errorMessage.value = result.message ?? 'Failed to load banners';
        }
      },
    );
    isBannerLoading.value = false;
  }

  Future<void> fetchVideos() async {
    isVideosLoading.value = true;
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getVideos();
        if (result.isSuccess && result.data != null) {
          videos.assignAll(result.data!);
        } else {
          errorMessage.value = result.message ?? 'Failed to load videos';
        }
      },
    );
    isVideosLoading.value = false;
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getCategories();
        if (result.isSuccess && result.data != null) {
          categories.assignAll(result.data!);
        } else {
          errorMessage.value = result.message ?? 'Failed to load categories';
        }
      },
    );
    isCategoriesLoading.value = false;
  }

  Future<void> retryAll() async {
    errorMessage.value = '';
    await Future.wait([
      fetchBanners(),
      fetchCategories(),
      fetchVideos(),
      fetchRecommendations(),
      fetchAnnouncements(),
      fetchWatchProgress(),
    ]);
  }

  WatchHistoryModel? watchProgressFor(String videoId) {
    final id = videoId.trim();
    if (id.isEmpty) return null;
    return watchHistoryById[id];
  }

  double progressValueFor(String videoId) {
    final progress = watchProgressFor(videoId);
    if (progress == null || progress.totalDuration <= 0) return 0;
    return (progress.watchedPosition / progress.totalDuration).clamp(0.0, 1.0);
  }

  bool hasWatchProgress(String videoId) {
    final progress = watchProgressFor(videoId);
    return progress != null &&
        progress.watchedPosition > 0 &&
        progress.totalDuration > 0;
  }

  String progressLabelFor(String videoId) {
    final progress = watchProgressFor(videoId);
    if (progress == null ||
        progress.watchedPosition <= 0 ||
        progress.totalDuration <= 0) {
      return '';
    }

    return '${_formatDuration(progress.watchedPosition)} / ${_formatDuration(progress.totalDuration)}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$remainingSeconds';
    }

    return '$minutes:$remainingSeconds';
  }

  Map<String, dynamic> _enrichWithWatchProgress(
    Map<String, dynamic> arguments,
  ) {
    final enriched = Map<String, dynamic>.from(arguments);
    final videoId = enriched['id']?.toString().trim() ?? '';
    final progress = watchProgressFor(videoId);
    if (progress == null) return enriched;

    enriched['title'] =
        (enriched['title']?.toString().trim().isNotEmpty ?? false)
        ? enriched['title']
        : progress.title;
    enriched['thumbnail'] =
        (enriched['thumbnail']?.toString().trim().isNotEmpty ?? false)
        ? enriched['thumbnail']
        : progress.thumbnail;
    enriched['videoUrl'] =
        (enriched['videoUrl']?.toString().trim().isNotEmpty ?? false)
        ? enriched['videoUrl']
        : progress.videoUrl;
    enriched['watchedPosition'] = progress.watchedPosition;
    enriched['lastPositionSeconds'] = progress.watchedPosition;

    return enriched;
  }

  Future<void> fetchRecommendations() async {
    isRecommendationsLoading.value = true;
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getRecommendations();
        if (result.isSuccess && result.data != null) {
          recommendations.assignAll(result.data!);
        } else {
          errorMessage.value =
              result.message ?? 'Failed to load recommendations';
        }
      },
    );
    isRecommendationsLoading.value = false;
  }

  Future<void> fetchAnnouncements() async {
    isAnnouncementsLoading.value = true;
    await makeApiCallWithRetry(
      context: Get.context!,
      apiCall: () async {
        final result = await _repository.getAnnouncements(
          page: 1,
          limit: 20,
          upcomingOnly: true,
        );
        if (result.isSuccess &&
            result.data != null &&
            result.data!.isNotEmpty) {
          announcements.assignAll(result.data!);
          return;
        }

        final fallbackResult = await _repository.getAnnouncements(
          page: 1,
          limit: 20,
          upcomingOnly: false,
        );

        if (fallbackResult.isSuccess && fallbackResult.data != null) {
          announcements.assignAll(fallbackResult.data!);
        } else {
          errorMessage.value =
              fallbackResult.message ?? 'Failed to load announcements';
        }
      },
    );
    isAnnouncementsLoading.value = false;
  }

  Future<void> onBannerTap(BannerItem banner) async {
    await playVideo({
      'id': banner.id,
      'title': banner.title,
      'thumbnail': banner.thumbnail,
      'description': banner.description,
      'duration': banner.duration,
      'videoUrl': banner.videoUrl,
    });
  }

  Future<void> onCategoryTap(CategoryItem category) async {
    final loggedIn = await ensureLoggedIn();
    if (!loggedIn) return;
    Get.toNamed(
      AppRoutes.categoryDetails,
      arguments: {'categoryId': category.id},
    );
  }

  Future<void> onVideoTap(VideoItem video) async {
    await playVideo({
      'id': video.id,
      'title': video.title,
      'thumbnail': video.thumbnail,
      'description': video.description,
      'duration': video.duration,
      'videoUrl': video.videoUrl,
      'audioTracks': video.audioTracks.map((t) => t.toJson()).toList(),
    });
  }

  Future<void> onRecommendationTap(RecommendationItem recommendation) async {
    await playVideo({
      'id': recommendation.id,
      'title': recommendation.title,
      'thumbnail': recommendation.thumbnail,
      'description': recommendation.description,
      'duration': recommendation.duration,
      'videoUrl': recommendation.videoUrl,
    });
  }

  Future<void> playVideo(Map<String, dynamic> arguments) async {
    final enrichedArguments = _enrichWithWatchProgress(arguments);
    final isLoggedIn = await _userData.checkLoginStatus();
    final hasToken = (_userData.accessToken ?? '').isNotEmpty;

    if (isLoggedIn && hasToken) {
      Get.toNamed(AppRoutes.videoPlayer, arguments: enrichedArguments);
      return;
    }

    await Get.bottomSheet<void>(
      LoginRequiredBottomSheet(
        onLoginPressed: () {
          Get.back<void>();
          Get.toNamed(
            AppRoutes.login,
            arguments: {
              'postLoginVideoArgs': Map<String, dynamic>.from(
                enrichedArguments,
              ),
            },
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void onClose() {
    _autoScrollTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}

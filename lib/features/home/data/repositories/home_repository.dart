import 'package:estoriz/core/base/api_result.dart';
import 'package:estoriz/features/home/data/models/announcement_model.dart';
import 'package:estoriz/features/home/data/models/banner_model.dart';
import 'package:estoriz/features/home/data/models/category_model.dart';
import 'package:estoriz/features/home/data/models/category_details_model.dart';
import 'package:estoriz/features/home/data/models/recommendation_model.dart';
import 'package:estoriz/features/home/data/models/video_model.dart'
    as video_model;
import 'package:estoriz/features/home/data/models/video_list_model.dart';
import 'package:estoriz/features/home/data/services/home_service.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<Result<List<BannerItem>>> getBanners() => _service.fetchBanners();

  Future<Result<List<CategoryItem>>> getCategories() =>
      _service.fetchCategories();

  Future<Result<CategoryDetailsItem>> getCategoryDetails(String categoryId) =>
      _service.fetchCategoryDetails(categoryId);

  Future<Result<List<video_model.VideoItem>>> getVideos() =>
      _service.fetchVideos();

  Future<Result<VideoListResponse>> getVideosByCategory(String categoryId) =>
      _service.fetchVideosByCategory(categoryId);

  Future<Result<List<RecommendationItem>>> getRecommendations() =>
      _service.fetchRecommendations();

  Future<Result<List<AnnouncementItem>>> getAnnouncements({
    int page = 1,
    int limit = 20,
    bool upcomingOnly = true,
  }) => _service.fetchAnnouncements(
    page: page,
    limit: limit,
    upcomingOnly: upcomingOnly,
  );
}

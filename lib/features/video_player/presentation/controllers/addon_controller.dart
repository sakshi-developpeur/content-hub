import 'package:get/get.dart';
import 'package:estoriz/features/video_player/controllers/video_player_controller.dart';
import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';
import 'package:estoriz/features/video_player/domain/usecases/get_addon_videos_use_case.dart';

class AddonController extends GetxController {
  AddonController(this._getAddonVideosUseCase);

  final GetAddonVideosUseCase _getAddonVideosUseCase;

  final RxList<AddonVideoModel> addonVideos = <AddonVideoModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  OttVideoPlayerController? _playerController;
  String _fallbackVideoId = '';
  String _fallbackThumbnail = '';

  void attachPlayerController(
    OttVideoPlayerController playerController, {
    String fallbackVideoId = '',
    String fallbackThumbnail = '',
  }) {
    _playerController = playerController;
    _fallbackVideoId = fallbackVideoId;
    _fallbackThumbnail = fallbackThumbnail;
  }

  Future<void> fetchAddonVideos(String contentId) async {
    final id = contentId.trim();
    if (id.isEmpty) {
      addonVideos.clear();
      errorMessage.value = '';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final videos = await _getAddonVideosUseCase.call(id);
      addonVideos.assignAll(videos);
    } catch (error) {
      addonVideos.clear();
      errorMessage.value = 'Unable to load related videos.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playAddonVideo(AddonVideoModel video) async {
    final player = _playerController;
    if (player == null) {
      errorMessage.value = 'Player is not ready.';
      return;
    }

    final source = video.hlsManifest.trim();
    if (source.isEmpty) {
      errorMessage.value = 'Selected recommended video has no playable source.';
      return;
    }

    await player.initVideo(
      source,
      autoPlay: true,
      videoId: video.id.isNotEmpty ? video.id : _fallbackVideoId,
      title: video.title,
      thumbnail: video.thumbnailUrl.isNotEmpty
          ? video.thumbnailUrl
          : _fallbackThumbnail,
      startPositionSeconds: 0,
    );
    player.updateTitle(video.title);
    errorMessage.value = '';
  }
}

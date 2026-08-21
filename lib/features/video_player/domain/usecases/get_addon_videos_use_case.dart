import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';
import 'package:estoriz/features/video_player/domain/repositories/addon_repository.dart';

class GetAddonVideosUseCase {
  GetAddonVideosUseCase(this._repository);

  final AddonRepository _repository;

  Future<List<AddonVideoModel>> call(String contentId) {
    return _repository.getAddonVideos(contentId);
  }
}

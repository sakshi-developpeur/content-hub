import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';

abstract class AddonRepository {
  Future<List<AddonVideoModel>> getAddonVideos(String contentId);
}

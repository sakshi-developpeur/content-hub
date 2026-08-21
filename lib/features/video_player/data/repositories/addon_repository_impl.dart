import 'package:estoriz/features/video_player/data/datasources/addon_remote_data_source.dart';
import 'package:estoriz/features/video_player/data/models/addon_video_model.dart';
import 'package:estoriz/features/video_player/domain/repositories/addon_repository.dart';

class AddonRepositoryImpl implements AddonRepository {
  AddonRepositoryImpl(this._remoteDataSource);

  final AddonRemoteDataSource _remoteDataSource;

  @override
  Future<List<AddonVideoModel>> getAddonVideos(String contentId) {
    return _remoteDataSource.fetchAddonVideos(contentId);
  }
}

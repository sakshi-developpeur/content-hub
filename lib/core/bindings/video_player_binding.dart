import 'package:get/get.dart';
import 'package:estoriz/features/video_player/data/datasources/addon_remote_data_source.dart';
import 'package:estoriz/features/video_player/data/repositories/addon_repository_impl.dart';
import 'package:estoriz/features/video_player/domain/repositories/addon_repository.dart';
import 'package:estoriz/features/video_player/domain/usecases/get_addon_videos_use_case.dart';
import 'package:estoriz/features/video_player/presentation/controllers/addon_controller.dart';

class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddonRemoteDataSource>(() => AddonRemoteDataSource());
    Get.lazyPut<AddonRepository>(
      () => AddonRepositoryImpl(Get.find<AddonRemoteDataSource>()),
    );
    Get.lazyPut<GetAddonVideosUseCase>(
      () => GetAddonVideosUseCase(Get.find<AddonRepository>()),
    );
    Get.lazyPut<AddonController>(
      () => AddonController(Get.find<GetAddonVideosUseCase>()),
    );
  }
}

import 'package:get/get.dart';
import '../../data/repositories/livestreaming_repository.dart';
import '../../data/services/livestreaming_service.dart';
import '../controllers/live_player_controller.dart';

class LivePlayerBinding extends Bindings {
  @override
  void dependencies() {
    // We assume the service and repository might already be in memory from the main list view,
    // but using Get.lazyPut ensure they are available here as well.
    Get.lazyPut<LivestreamingService>(() => LivestreamingService());
    Get.lazyPut<LivestreamingRepository>(() => LivestreamingRepository(Get.find<LivestreamingService>()));
    Get.lazyPut<LivePlayerController>(() => LivePlayerController(Get.find<LivestreamingRepository>()));
  }
}

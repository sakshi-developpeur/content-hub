import 'package:get/get.dart';
import '../../data/repositories/livestreaming_repository.dart';
import '../../data/services/livestreaming_service.dart';
import '../controllers/livestreaming_controller.dart';

class LivestreamingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LivestreamingService>(() => LivestreamingService());
    Get.lazyPut<LivestreamingRepository>(
      () => LivestreamingRepository(Get.find<LivestreamingService>()),
    );
    Get.lazyPut<LivestreamingController>(
      () => LivestreamingController(Get.find<LivestreamingRepository>()),
    );
  }
}

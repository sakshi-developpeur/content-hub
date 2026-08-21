import 'package:get/get.dart';
import 'package:estoriz/features/dashboard/controller/dashboard_controller.dart';
import 'package:estoriz/features/home/data/repositories/home_repository.dart';
import 'package:estoriz/features/home/data/services/home_service.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';
import 'package:estoriz/features/profile/controller/profile_selection_controller.dart';
import 'package:estoriz/features/search/controller/search_controller.dart';
import 'package:estoriz/features/search/data/services/search_service.dart';
import 'package:estoriz/features/livestreaming/data/services/livestreaming_service.dart';
import 'package:estoriz/features/livestreaming/data/repositories/livestreaming_repository.dart';
import 'package:estoriz/features/livestreaming/presentation/controllers/livestreaming_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController(), permanent: true);
    }
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeService>(() => HomeService());
    Get.lazyPut<HomeRepository>(() => HomeRepository(Get.find<HomeService>()));
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SearchService>(() => SearchService());
    Get.lazyPut<SearchController>(
      () => SearchController(Get.find<SearchService>()),
    );
    Get.lazyPut<LivestreamingService>(() => LivestreamingService());
    Get.lazyPut<LivestreamingRepository>(
      () => LivestreamingRepository(Get.find<LivestreamingService>()),
    );
    Get.lazyPut<LivestreamingController>(
      () => LivestreamingController(Get.find<LivestreamingRepository>()),
    );
  }
}

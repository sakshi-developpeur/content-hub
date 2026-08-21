import 'package:get/get.dart';
import 'package:estoriz/features/home/data/repositories/home_repository.dart';
import 'package:estoriz/features/home/data/services/home_service.dart';
import 'package:estoriz/features/home/presentation/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(() => HomeService());
    Get.lazyPut<HomeRepository>(() => HomeRepository(Get.find<HomeService>()));
    Get.lazyPut<HomeController>(() => HomeController());
  }
}


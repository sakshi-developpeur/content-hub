import 'package:get/get.dart';
import 'package:estoriz/features/watchlist/presentation/controllers/watchlist_controller.dart';

class WatchlistBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WatchlistController>()) {
      Get.put<WatchlistController>(WatchlistController(), permanent: true);
    }
  }
}

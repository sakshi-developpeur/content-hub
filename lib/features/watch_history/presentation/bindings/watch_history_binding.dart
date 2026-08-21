import 'package:get/get.dart';
import 'package:estoriz/features/watch_history/data/repositories/watch_history_repository.dart';
import 'package:estoriz/features/watch_history/presentation/controllers/watch_history_controller.dart';

class WatchHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchHistoryRepository>(() => WatchHistoryRepository());
    Get.lazyPut<WatchHistoryController>(
      () => WatchHistoryController(
        repository: Get.find<WatchHistoryRepository>(),
      ),
    );
  }
}

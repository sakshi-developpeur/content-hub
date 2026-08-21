import 'package:get/get.dart';
import 'package:estoriz/features/home/presentation/controllers/category_details_controller.dart';

class CategoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryDetailsController>(() => CategoryDetailsController());
  }
}


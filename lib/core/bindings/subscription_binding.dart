import 'package:get/get.dart';
import 'package:estoriz/features/subscription/controller/subscription_controller.dart';
import 'package:estoriz/features/subscription/data/services/subscription_service.dart';
import 'package:estoriz/features/subscription/data/services/payment_service.dart';
import 'package:estoriz/features/subscription/data/services/iap_service.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionService>(() => SubscriptionService());
    Get.lazyPut<PaymentService>(() => PaymentService());
    Get.lazyPut<IapService>(() => IapService());
    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(
        subscriptionService: Get.find<SubscriptionService>(),
        paymentService: Get.find<PaymentService>(),
        iapService: Get.find<IapService>(),
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/features/profile/model/user_profile_model.dart';
import 'package:estoriz/features/profile/service/profile_service.dart';
import 'package:estoriz/models/user_model.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:get_storage/get_storage.dart';

class UserProfileController extends BaseController {
  final ProfileService _profileService = ProfileService();
  final RxList<UserProfileModel> profiles = <UserProfileModel>[].obs;
  final Rxn<UserModel> currentUserData = Rxn<UserModel>();
  final RxString activeAvatar = ''.obs;
  final RxString activeProfileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshUserData();
    fetchProfiles();
  }

  void refreshUserData() {
    currentUserData.value = UserData().currentUser;
    final box = GetStorage();
    activeAvatar.value = box.read('active_profile_avatar') ?? '';
    activeProfileName.value = box.read('active_profile_name') ?? '';
  }

  Future<void> fetchProfiles() async {
    setLoadingState(true);
    try {
      final fetchedProfiles = await _profileService.getProfiles();
      profiles.assignAll(fetchedProfiles);
    } catch (e) {
      showErrorMessage(message: 'Failed to fetch profiles: ${e.toString()}');
    } finally {
      setLoadingState(false);
    }
  }
}

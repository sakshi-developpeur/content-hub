import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:estoriz/core/base/baseController.dart';
import 'package:estoriz/core/routes/app_routes.dart';
import 'package:estoriz/features/profile/model/profile_model.dart';

class ProfileController extends BaseController {
  static const String _profilesKey = 'ott_profiles';
  static const String _activeProfileKey = 'active_profile_id';
  static const String _activeProfileAvatarKey = 'active_profile_avatar';
  static const String _activeProfileNameKey = 'active_profile_name';

  final GetStorage _box = GetStorage();

  final RxList<ProfileModel> profiles = <ProfileModel>[].obs;
  final RxString selectedAvatar = ''.obs;
  final TextEditingController nameController = TextEditingController();
  final RxnString activeProfileId = RxnString();
  final RxBool isKids = false.obs;
  final RxBool isEditMode = false.obs;
  final Rxn<ProfileModel> editingProfile = Rxn<ProfileModel>();

  final List<String> avatarOptions = const [
    'assets/avatars/avtar1.avif',
    'assets/avatars/avtar2.jpg',
    'assets/avatars/avtar3.jpg',
    'assets/avatars/avater4.png',
    'assets/avatars/avtar5.png',
    'assets/avatars/avater6.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final raw = _box.read(_profilesKey);
    if (raw is List) {
      profiles.assignAll(
        raw
            .whereType<Map>()
            .map((e) => ProfileModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    if (profiles.isEmpty) {
      profiles.assignAll([
        const ProfileModel(
          id: '1',
          name: 'Main',
          avatar: 'assets/avatars/avtar1.avif',
          isMain: true,
        ),
        const ProfileModel(
          id: '2',
          name: 'Kids',
          avatar: 'assets/avatars/avtar2.jpg',
          isKids: true,
        ),
      ]);
      await _saveProfiles();
    }

    activeProfileId.value = _box.read(_activeProfileKey)?.toString();

    if (avatarOptions.isNotEmpty && selectedAvatar.value.isEmpty) {
      selectedAvatar.value = avatarOptions.first;
    }
  }

  Future<void> _saveProfiles() async {
    await _box.write(_profilesKey, profiles.map((e) => e.toJson()).toList());
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  void selectAvatar(String avatar) {
    selectedAvatar.value = avatar;
  }

  Future<void> selectAndStoreActiveProfile(ProfileModel profile) async {
    activeProfileId.value = profile.id;
    await _box.write(_activeProfileKey, profile.id);
    await _box.write(_activeProfileAvatarKey, profile.avatar);
    await _box.write(_activeProfileNameKey, profile.name);
  }

  Future<void> onProfileSelected(ProfileModel profile) async {
    if (isEditMode.value) {
      openEditProfile(profile);
    } else {
      final loggedIn = await ensureLoggedIn();
      if (!loggedIn) return;
      await selectAndStoreActiveProfile(profile);
      showSuccessMessage(message: 'Welcome back, ${profile.name}!');
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  void openEditProfile(ProfileModel profile) {
    editingProfile.value = profile;
    nameController.text = profile.name;
    selectedAvatar.value = profile.avatar;
    isKids.value = profile.isKids;
    Get.toNamed(AppRoutes.createProfile);
  }

  Future<bool> saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showWarningMessage(message: 'Please enter your name');
      return false;
    }

    if (selectedAvatar.value.isEmpty) {
      showWarningMessage(message: 'Please select an avatar');
      return false;
    }

    final editing = editingProfile.value;
    if (editing != null) {
      // Update existing profile
      final index = profiles.indexWhere((p) => p.id == editing.id);
      if (index >= 0) {
        profiles[index] = ProfileModel(
          id: editing.id,
          name: name,
          avatar: selectedAvatar.value,
          isKids: isKids.value,
        );

        if (editing.id == activeProfileId.value) {
          await _box.write(_activeProfileAvatarKey, selectedAvatar.value);
          await _box.write(_activeProfileNameKey, name);
        }
      }
      editingProfile.value = null;
      await _saveProfiles();
      clearCreateProfileInputs();
      showSuccessMessage(message: 'Profile updated successfully');
    } else {
      // Create new profile
      final profile = ProfileModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        avatar: selectedAvatar.value,
        isKids: isKids.value,
      );
      profiles.add(profile);
      await _saveProfiles();
      clearCreateProfileInputs();
      showSuccessMessage(message: 'Profile created successfully');
    }
    return true;
  }

  void clearCreateProfileInputs() {
    nameController.clear();
    isKids.value = false;
    if (avatarOptions.isNotEmpty) {
      selectedAvatar.value = avatarOptions.first;
    }
  }

  Future<void> deleteProfile(ProfileModel profile) async {
    if (!profile.isDeletable) return;
    profiles.removeWhere((p) => p.id == profile.id);
    await _saveProfiles();

    if (profile.id == activeProfileId.value) {
      final fallback = profiles.isNotEmpty ? profiles.first : null;
      if (fallback != null) {
        await selectAndStoreActiveProfile(fallback);
      } else {
        activeProfileId.value = null;
        await _box.remove(_activeProfileKey);
        await _box.remove(_activeProfileAvatarKey);
        await _box.remove(_activeProfileNameKey);
      }
    }

    editingProfile.value = null;
    clearCreateProfileInputs();
    Get.until((route) => route.settings.name == AppRoutes.profileSelection);
  }

  void onAddProfile() {
    clearCreateProfileInputs();
    Get.toNamed(AppRoutes.createProfile);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

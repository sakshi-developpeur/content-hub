import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:estoriz/features/profile/controller/profile_selection_controller.dart';

class CreateProfileView extends StatefulWidget {
  const CreateProfileView({super.key});

  @override
  State<CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  late final ProfileController controller;
  late final PageController _pageController;

  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();

    final initialIndex = controller.avatarOptions.indexOf(
      controller.selectedAvatar.value,
    );
    final safeInitialIndex = initialIndex >= 0 ? initialIndex : 0;

    _currentPage = safeInitialIndex.toDouble();
    _pageController =
        PageController(viewportFraction: 0.34, initialPage: safeInitialIndex)
          ..addListener(() {
            setState(() {
              _currentPage = _pageController.page ?? _currentPage;
            });
          });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProfileController ctrl,
  ) async {
    final profile = ctrl.editingProfile.value;
    if (profile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${profile.name}"?',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ctrl.deleteProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101115),
        title: Obx(
          () => Text(
            controller.editingProfile.value != null
                ? 'Edit Profile'
                : 'Create Profile',
          ),
        ),
        actions: [
          Obx(
            () => controller.editingProfile.value?.isDeletable == true
                ? TextButton(
                    onPressed: () => _confirmDelete(context, controller),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: controller.avatarOptions.length,
                  onPageChanged: (index) {
                    controller.selectAvatar(controller.avatarOptions[index]);
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final avatar = controller.avatarOptions[index];
                    final distance = (_currentPage - index).abs();
                    final clampedDistance = math.min(distance, 1.0);
                    final scale = 1 - (clampedDistance * 0.28);
                    final translateY = clampedDistance * 20;
                    final isSelected =
                        distance < 0.5 &&
                        controller.selectedAvatar.value == avatar;

                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                        );
                        controller.selectAvatar(avatar);
                        setState(() {});
                      },
                      child: Transform.translate(
                        offset: Offset(0, translateY),
                        child: Transform.scale(
                          scale: scale,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF40C4FF),
                                        Color(0xFF3DDC84),
                                      ],
                                    )
                                  : null,
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.white24,
                                      width: 1.5,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF40C4FF,
                                        ).withValues(alpha: 0.45),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(avatar),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.07),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF40C4FF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3DDC84),
        onPressed: () async {
          final ok = await controller.saveProfile();
          if (ok) {
            Get.back();
          }
        },
        child: const Icon(Icons.check, color: Colors.black),
      ),
    );
  }
}

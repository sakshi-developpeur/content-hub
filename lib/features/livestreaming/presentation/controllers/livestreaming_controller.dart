import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/live_event_model.dart';
import '../../data/models/agora_join_result_model.dart';
import '../../data/repositories/livestreaming_repository.dart';
import 'package:estoriz/core/routes/app_routes.dart';

class LivestreamingController extends GetxController {
  final LivestreamingRepository _repository;

  LivestreamingController(this._repository);

  final RxBool isLoading = false.obs;
  final RxList<LiveEvent> liveEvents = <LiveEvent>[].obs;
  final RxString errorMessage = ''.obs;

  // Pagination & Filtering
  int _currentPage = 1;
  bool _hasMore = true;
  final RxString searchQuery = ''.obs;
  final RxString currentStatus = 'all'.obs; // all, live, scheduled, ended, cancelled
  
  Timer? _debounce;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchLiveEvents(refresh: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  List<LiveEvent> get liveEventsOnly =>
      liveEvents.where((e) => e.isLive).toList();
  List<LiveEvent> get upcomingEventsOnly =>
      liveEvents.where((e) => e.isUpcoming).toList();

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && _hasMore) {
        fetchLiveEvents();
      }
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      fetchLiveEvents(refresh: true);
    });
  }

  void setStatusFilter(String status) {
    currentStatus.value = status;
    fetchLiveEvents(refresh: true);
  }

  Future<void> fetchLiveEvents({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      liveEvents.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getLiveEvents(
        page: _currentPage,
        limit: 20,
        status: currentStatus.value == 'all' ? null : currentStatus.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (result.isSuccess) {
        final newEvents = result.data ?? [];
        if (newEvents.length < 20) {
          _hasMore = false;
        }
        liveEvents.addAll(newEvents);
        _currentPage++;
        
        // Removed dummy data to ensure we only use real API data
        // if (liveEvents.isEmpty && searchQuery.value.isEmpty && currentStatus.value == 'all') {
        //   _setDummyData();
        // }
      } else {
        errorMessage.value = result.message ?? 'Failed to load streams';
        // if (liveEvents.isEmpty) _setDummyData();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      // if (liveEvents.isEmpty) _setDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinLivestream(LiveEvent event) async {
    // If it's a dummy event or doesn't have an ID, we might just fall back to standard video player
    // or handle it gracefully. For now, we will attempt the API.
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await _repository.joinLivestream(event.id);
      Get.back(); // close loading dialog

      if (result.isSuccess && result.data != null) {
        final joinData = result.data!;
        Get.toNamed(
          AppRoutes.livePlayer, // We need to define this route
          arguments: {
            'event': event,
            'agoraData': joinData.agora,
          },
        );
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to join livestream',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // close loading dialog
      Get.snackbar(
        'Error',
        'Failed to join livestream: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _setDummyData() {
    liveEvents.value = [
      LiveEvent(
        id: '69f9bd97e017be9199b15d8c', // Matches example API
        title: 'Flutter Advanced Masterclass',
        description: 'Deep dive into advanced Flutter patterns and performance optimization.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1628258334807-290b507203f9?w=800&q=80',
        status: 'live',
        visibility: 'all',
        hostId: 'host123',
        hostName: 'Teacher A',
        viewerCount: 150,
      ),
      LiveEvent(
        id: '2',
        title: 'Dart 3.0 New Features',
        description: 'Learn about records, patterns, and other cool features in Dart 3.0.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&q=80',
        status: 'scheduled',
        visibility: 'all',
        hostId: 'host123',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
      ),
    ];
  }
}

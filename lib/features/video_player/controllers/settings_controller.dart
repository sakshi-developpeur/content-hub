import 'package:better_player_plus/better_player_plus.dart';
import 'package:get/get.dart';
import 'package:estoriz/features/video_player/controllers/video_player_controller.dart';

/// Manages player settings (audio language, quality).
///
/// When an [OttVideoPlayerController] is attached, language changes
/// are forwarded to the underlying BetterPlayer HLS audio track API.
class SettingsController extends GetxController {
  final RxString selectedLanguage = 'English'.obs;
  final RxString selectedQuality = 'Auto'.obs;

  OttVideoPlayerController? _playerController;

  /// Attach the player controller so language changes can be applied.
  void attachPlayer(OttVideoPlayerController controller) {
    _playerController = controller;
  }

  /// Detach the player controller (e.g. when the player view disposes).
  void detachPlayer() {
    _playerController = null;
  }

  /// Returns the list of available HLS audio tracks from the player.
  List<BetterPlayerAsmsAudioTrack> get availableAudioTracks {
    return _playerController?.hlsAudioTracks ?? [];
  }

  /// Sets the audio language by selecting the matching HLS audio track.
  void setLanguage(String language) {
    selectedLanguage.value = language;

    final controller = _playerController;
    if (controller == null) return;

    // Try to match by label first (e.g. "Hindi"), then by language code
    final track = controller.findTrackByLabel(language) ??
        controller.findTrackByLanguageCode(_languageToCode(language));

    if (track != null) {
      controller.setAudioTrack(track);
    }
  }

  /// Sets the video quality. (Placeholder — HLS adaptive quality
  /// is handled automatically by BetterPlayer.)
  void setQuality(String quality) {
    selectedQuality.value = quality;
  }

  /// Maps common display names to ISO language codes.
  String _languageToCode(String name) {
    switch (name.toLowerCase()) {
      case 'hindi':
        return 'hi';
      case 'english':
        return 'en';
      case 'tamil':
        return 'ta';
      case 'telugu':
        return 'te';
      case 'bengali':
        return 'bn';
      case 'marathi':
        return 'mr';
      case 'gujarati':
        return 'gu';
      case 'kannada':
        return 'kn';
      case 'malayalam':
        return 'ml';
      case 'punjabi':
        return 'pa';
      default:
        return name.toLowerCase();
    }
  }
}

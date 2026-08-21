import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:estoriz/features/watchlist/data/models/video_model.dart';

class LocalStorageService {
  static const String _watchlistKey = 'watchlist_videos';

  Future<void> saveWatchlist(List<VideoModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = watchlist
        .map((video) => jsonEncode(video.toJson()))
        .toList();
    await prefs.setStringList(_watchlistKey, encoded);
  }

  Future<List<VideoModel>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_watchlistKey) ?? <String>[];

    return encoded
        .map((item) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            return VideoModel.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<VideoModel>()
        .where((video) => video.id.isNotEmpty)
        .toList(growable: false);
  }
}

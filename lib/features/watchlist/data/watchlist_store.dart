import 'package:get_storage/get_storage.dart';

class WatchlistItem {
  final String id;
  final String title;
  final String thumbnail;
  final String? videoUrl;
  final String? description;
  final String? duration;
  final DateTime addedAt;

  const WatchlistItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.videoUrl,
    this.description,
    this.duration,
    required this.addedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      description: json['description']?.toString(),
      duration: json['duration']?.toString(),
      addedAt:
          DateTime.tryParse(json['addedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'description': description,
      'duration': duration,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class WatchlistStore {
  static const String _key = 'watchlist_items';
  final GetStorage _box = GetStorage();

  List<WatchlistItem> getItems() {
    final raw = _box.read<List<dynamic>>(_key) ?? <dynamic>[];
    final list = raw
        .whereType<Map>()
        .map((e) => WatchlistItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);

    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  bool contains(String id) {
    if (id.isEmpty) return false;
    return getItems().any((item) => item.id == id);
  }

  bool toggleItem(WatchlistItem item) {
    final items = getItems().toList(growable: true);
    final index = items.indexWhere((e) => e.id == item.id);

    if (index >= 0) {
      items.removeAt(index);
      _save(items);
      return false;
    }

    items.insert(0, item);
    _save(items);
    return true;
  }

  void removeById(String id) {
    final items = getItems().where((e) => e.id != id).toList(growable: false);
    _save(items);
  }

  void _save(List<WatchlistItem> items) {
    _box.write(_key, items.map((e) => e.toJson()).toList(growable: false));
  }
}


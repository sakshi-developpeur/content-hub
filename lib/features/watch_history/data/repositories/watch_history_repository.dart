import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:estoriz/api_helper/endpoints.dart';
import 'package:estoriz/core/utils/user_data.dart';
import 'package:estoriz/features/watch_history/data/models/watch_history_model.dart';

class WatchHistoryRepository {
  static const String _baseUrl = 'http://13.203.145.200:8004/api/';
  static const String _localKey = 'watch_history_cache_v2';

  final UserData _userData;
  late final Dio _dio;

  WatchHistoryRepository({UserData? userData})
    : _userData = userData ?? UserData() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _userData.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<List<WatchHistoryModel>> fetchWatchHistory() async {
    try {
      final response = await _dio.get(Endpoints.watchHistory);
      final remoteItems = _parseList(response.data);
      final localItems = await _loadLocal();
      final merged = _mergePreferRich(localItems, remoteItems);
      final deduped = _dedupeAndSort(merged);
      await _saveLocal(deduped);
      return deduped;
    } catch (_) {
      final local = await _loadLocal();
      return _dedupeAndSort(local);
    }
  }

  Future<void> addOrUpdateHistory(WatchHistoryModel model) async {
    if (model.videoId.isEmpty) return;

    final payload = {
      'videoId': model.videoId,
      'title': model.title,
      'thumbnail': model.thumbnail,
      'videoUrl': model.videoUrl,
      'totalDuration': model.totalDuration,
      'watchedPosition': model.watchedPosition,
      'lastPositionSeconds': model.watchedPosition,
      'completed':
          model.totalDuration > 0 &&
          model.watchedPosition >= model.totalDuration,
      'lastWatched': model.lastWatched.toIso8601String(),
    };

    try {
      await _dio.post(Endpoints.watchHistory, data: payload);
    } catch (_) {
      // Keep local cache in sync even when offline.
    }

    final local = await _loadLocal();
    final idx = local.indexWhere((item) => item.videoId == model.videoId);
    if (idx >= 0) {
      local[idx] = model;
    } else {
      local.add(model);
    }

    await _saveLocal(_dedupeAndSort(local));
  }

  Future<WatchHistoryModel> ensurePlayableData(WatchHistoryModel model) async {
    if (model.videoUrl.trim().isNotEmpty) {
      return model;
    }

    if (model.videoId.trim().isEmpty) {
      return model;
    }

    try {
      final response = await _dio.get('${Endpoints.videos}/${model.videoId}');
      final enrichedFromSingle = _mergeModelWithRaw(model, response.data);
      if (enrichedFromSingle.videoUrl.trim().isNotEmpty) {
        await addOrUpdateHistory(enrichedFromSingle);
        return enrichedFromSingle;
      }
    } catch (_) {
      // Fall through to list-based lookup.
    }

    try {
      // Fallback when single-video endpoint is unavailable: search in videos list.
      for (var page = 1; page <= 5; page++) {
        final response = await _dio.get(
          Endpoints.videos,
          queryParameters: {'page': page, 'limit': 100},
        );

        final found = _findVideoByIdInVideoListResponse(
          raw: response.data,
          videoId: model.videoId,
        );
        if (found == null) {
          continue;
        }

        final enriched = _mergeModelWithRaw(model, found);
        if (enriched.videoUrl.trim().isNotEmpty) {
          await addOrUpdateHistory(enriched);
          return enriched;
        }
      }
    } catch (_) {
      // Ignore fallback errors and return the original model.
    }

    return model;
  }

  WatchHistoryModel _mergeModelWithRaw(WatchHistoryModel base, dynamic raw) {
    Map<String, dynamic>? map;

    Map<String, dynamic>? asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        // { data: { video: {...} } } OR { data: { ...videoFields... } }
        map = asMap(data['video']) ?? data;
      } else if (data is List && data.isNotEmpty) {
        // { data: [ {...} ] }
        map = asMap(data.first);
      } else {
        // Flat video object or { video: {...} } top-level wrapper
        map = asMap(raw['video']) ?? raw;
      }
    } else if (raw is List && raw.isNotEmpty) {
      map = asMap(raw.first);
    }

    if (map == null) {
      return base;
    }

    final parsed = WatchHistoryModel.fromJson(map);
    return base.copyWith(
      title: (parsed.title == 'Untitled' || parsed.title.trim().isEmpty)
          ? base.title
          : parsed.title,
      thumbnail: parsed.thumbnail.trim().isEmpty
          ? base.thumbnail
          : parsed.thumbnail,
      videoUrl: parsed.videoUrl.trim().isEmpty
          ? base.videoUrl
          : parsed.videoUrl,
    );
  }

  Map<String, dynamic>? _findVideoByIdInVideoListResponse({
    required dynamic raw,
    required String videoId,
  }) {
    final target = videoId.trim();
    if (target.isEmpty) return null;

    final candidates = <Map<String, dynamic>>[];

    void addMap(dynamic value) {
      if (value is Map<String, dynamic>) {
        candidates.add(value);
      } else if (value is Map) {
        candidates.add(Map<String, dynamic>.from(value));
      }
    }

    void addList(dynamic value) {
      if (value is! List) return;
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          addMap(item);
          // Grouped shape: { videos: [...] }
          final grouped = item['videos'];
          if (grouped is List) {
            for (final nested in grouped) {
              addMap(nested);
            }
          }
        } else if (item is Map) {
          addMap(item);
        }
      }
    }

    if (raw is Map<String, dynamic>) {
      addMap(raw['data']);
      addList(raw['data']);
      addList(raw['videos']);
      addList(raw['items']);
      addList(raw['results']);
    } else {
      addList(raw);
    }

    for (final item in candidates) {
      final id = (item['_id'] ?? item['id'])?.toString() ?? '';
      if (id == target) {
        return item;
      }
    }

    return null;
  }

  List<WatchHistoryModel> _parseList(dynamic raw) {
    final data = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : raw;

    List<dynamic> list = const <dynamic>[];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = _firstList([
        data['watchHistory'],
        data['history'],
        data['items'],
        data['docs'],
        data['results'],
        data['data'],
        data['videos'],
      ]);
    }

    return list
        .whereType<Map>()
        .map((e) => WatchHistoryModel.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.videoId.isNotEmpty)
        .toList(growable: false);
  }

  List<dynamic> _firstList(List<dynamic> values) {
    for (final value in values) {
      if (value is List) return value;
    }
    return const <dynamic>[];
  }

  List<WatchHistoryModel> _mergePreferRich(
    List<WatchHistoryModel> local,
    List<WatchHistoryModel> remote,
  ) {
    final byId = <String, WatchHistoryModel>{};

    for (final item in local) {
      byId[item.videoId] = item;
    }

    for (final item in remote) {
      final existing = byId[item.videoId];
      if (existing == null) {
        byId[item.videoId] = item;
        continue;
      }

      final merged = item.copyWith(
        title: (item.title.trim().isEmpty || item.title == 'Untitled')
            ? existing.title
            : item.title,
        thumbnail: item.thumbnail.trim().isEmpty
            ? existing.thumbnail
            : item.thumbnail,
        videoUrl: item.videoUrl.trim().isEmpty
            ? existing.videoUrl
            : item.videoUrl,
        totalDuration: item.totalDuration > 0
            ? item.totalDuration
            : existing.totalDuration,
        watchedPosition: item.watchedPosition > 0
            ? item.watchedPosition
            : existing.watchedPosition,
        lastWatched: item.lastWatched.isAfter(existing.lastWatched)
            ? item.lastWatched
            : existing.lastWatched,
      );

      byId[item.videoId] = merged;
    }

    return byId.values.toList(growable: false);
  }

  List<WatchHistoryModel> _dedupeAndSort(List<WatchHistoryModel> source) {
    final map = <String, WatchHistoryModel>{};

    for (final item in source) {
      final existing = map[item.videoId];
      if (existing == null || item.lastWatched.isAfter(existing.lastWatched)) {
        map[item.videoId] = item;
      }
    }

    final values = map.values.toList(growable: false)
      ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    return values;
  }

  Future<void> _saveLocal(List<WatchHistoryModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_localKey, encoded);
  }

  Future<List<WatchHistoryModel>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localKey) ?? <String>[];

    return raw
        .map((entry) {
          try {
            return WatchHistoryModel.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<WatchHistoryModel>()
        .where((item) => item.videoId.isNotEmpty)
        .toList(growable: false);
  }
}

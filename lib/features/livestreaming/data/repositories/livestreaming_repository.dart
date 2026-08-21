import 'package:estoriz/core/base/api_result.dart';
import '../models/live_event_model.dart';
import '../models/agora_join_result_model.dart';
import '../services/livestreaming_service.dart';

class LivestreamingRepository {
  final LivestreamingService _service;

  LivestreamingRepository(this._service);

  Future<Result<List<LiveEvent>>> getLiveEvents({
    int page = 1,
    int limit = 20,
    String? status,
    bool? upcoming,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    return await _service.fetchLiveEvents(
      page: page,
      limit: limit,
      status: status,
      upcoming: upcoming,
      sortBy: sortBy,
      sortOrder: sortOrder,
      search: search,
    );
  }

  Future<Result<LiveEvent>> getLiveEventById(String id) async {
    return await _service.fetchLiveEventById(id);
  }

  Future<Result<AgoraJoinResult>> joinLivestream(String id) async {
    return await _service.joinLivestream(id);
  }

  Future<Result<int>> sendHeartbeat(String id) async {
    return await _service.sendHeartbeat(id);
  }
}

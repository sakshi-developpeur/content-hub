import 'package:estoriz/api_helper/api_client.dart';
import 'package:estoriz/features/profile/model/user_profile_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserProfileModel>> getProfiles() async {
    try {
      final response = await _apiClient.get('profiles');
      
      if (response is List) {
        return response.map((e) => UserProfileModel.fromJson(e)).toList();
      }
      
      if (response is Map<String, dynamic>) {
        if (response['success'] == true || response.containsKey('data')) {
          final dynamic data = response['data'];
          if (data is List) {
            return data.map((e) => UserProfileModel.fromJson(e)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

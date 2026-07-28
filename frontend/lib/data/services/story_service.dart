import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/story.dart';
import '../models/user.dart';

class StoryService {
  final ApiService _api;

  StoryService(this._api);

  Future<List<StoryGroup>> getStories() async {
    final response = await _api.get('/stories/list');
    return (response.data as List).map((e) {
      return StoryGroup(
        user: User.fromJson(e['user']),
        stories: (e['stories'] as List).map((s) => Story.fromJson(s)).toList(),
      );
    }).toList();
  }

  Future<List<Story>> getUserStories(String userId) async {
    final response = await _api.get('/stories/user/$userId');
    return (response.data as List).map((e) => Story.fromJson(e)).toList();
  }

  Future<Story> createStory(String mediaUrl, String type) async {
    final response = await _api.post('/stories/create', data: {
      'mediaUrl': mediaUrl,
      'type': type,
    });
    return Story.fromJson(response.data);
  }

  Future<void> deleteStory(String storyId) async {
    await _api.delete('/stories/$storyId');
  }
}

final storyServiceProvider = Provider<StoryService>((ref) {
  final apiService = ApiService();
  return StoryService(apiService);
});

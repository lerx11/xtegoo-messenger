import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/call.dart';

class CallService {
  final ApiService _api;

  CallService(this._api);

  Future<List<Call>> getHistory() async {
    final response = await _api.get('/calls/history');
    return (response.data as List).map((e) => Call.fromJson(e)).toList();
  }

  Future<Call> createCall(String receiverId, String type) async {
    final response = await _api.post('/calls/create', data: {
      'receiverId': receiverId,
      'type': type,
    });
    return Call.fromJson(response.data);
  }

  Future<String> getLiveKitToken(String roomName, String participantName) async {
    final response = await _api.post('/calls/livekit-token', data: {
      'roomName': roomName,
      'participantName': participantName,
    });
    return response.data['token'];
  }

  Future<void> updateStatus(String callId, String status, {int? duration}) async {
    await _api.put('/calls/$callId/status', data: {
      'status': status,
      if (duration != null) 'duration': duration,
    });
  }
}

final callServiceProvider = Provider<CallService>((ref) {
  final apiService = ApiService();
  return CallService(apiService);
});

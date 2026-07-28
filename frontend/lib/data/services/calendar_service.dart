import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/calendar_event.dart';
import '../models/marketplace.dart';

class CalendarService {
  final ApiService _api;

  CalendarService(this._api);

  Future<List<CalendarEvent>> getEvents({DateTime? startDate, DateTime? endDate}) async {
    final response = await _api.get('/calendar/events', queryParameters: {
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    return (response.data as List).map((e) => CalendarEvent.fromJson(e)).toList();
  }

  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final response = await _api.post('/calendar/events', data: event.toJson());
    return CalendarEvent.fromJson(response.data);
  }

  Future<CalendarEvent> updateEvent(String eventId, Map<String, dynamic> data) async {
    final response = await _api.put('/calendar/events/$eventId', data: data);
    return CalendarEvent.fromJson(response.data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _api.delete('/calendar/events/$eventId');
  }

  Future<Booking> createBooking(String serviceId, DateTime date) async {
    final response = await _api.post('/calendar/bookings', data: {
      'serviceId': serviceId,
      'date': date.toIso8601String(),
    });
    return Booking.fromJson(response.data);
  }

  Future<List<Booking>> getMyBookings() async {
    final response = await _api.get('/calendar/bookings/my');
    return (response.data as List).map((e) => Booking.fromJson(e)).toList();
  }

  Future<List<Booking>> getBusinessBookings() async {
    final response = await _api.get('/calendar/bookings/business');
    return (response.data as List).map((e) => Booking.fromJson(e)).toList();
  }
}

final calendarServiceProvider = Provider<CalendarService>((ref) {
  final apiService = ApiService();
  return CalendarService(apiService);
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/medical_event.dart';

final eventApiProvider = Provider<EventApi>((ref) {
  return EventApi(ref.watch(apiClientProvider));
});

class EventApi {
  const EventApi(this._dio);

  final Dio _dio;

  Future<MedicalEvent> getEvent(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/events/$id');
      return MedicalEvent.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<MedicalEvent> createEvent(EventWriteRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/events',
        data: request.toJson(),
      );
      return MedicalEvent.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<MedicalEvent> updateEvent(String id, EventWriteRequest request) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/events/$id',
        data: request.toJson(),
      );
      return MedicalEvent.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _dio.delete<void>('/events/$id');
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

class EventWriteRequest {
  const EventWriteRequest({
    required this.eventType,
    required this.title,
    required this.eventDate,
    required this.subjectId,
    this.description = '',
    this.eventEndDate,
    this.attributes = const <String, dynamic>{},
    this.tags = const <String>[],
  });

  final MedicalEventType eventType;
  final String title;
  final String description;
  final String eventDate;
  final String? eventEndDate;
  final Map<String, dynamic> attributes;
  final List<String> tags;
  final String subjectId;

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType.apiName,
      'title': title,
      'description': description,
      'event_date': eventDate,
      'event_end_date': eventEndDate,
      'attributes': attributes,
      'tags': tags,
      'subject_id': subjectId,
      'source': 'user_manual',
    };
  }
}

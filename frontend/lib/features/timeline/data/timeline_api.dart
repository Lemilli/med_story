import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../events/domain/medical_event.dart';
import '../domain/timeline_filters.dart';

final timelineApiProvider = Provider<TimelineApi>((ref) {
  return TimelineApi(ref.watch(apiClientProvider));
});

class TimelineApi {
  const TimelineApi(this._dio);

  final Dio _dio;

  Future<TimelinePage> fetchTimeline({
    required String subjectId,
    TimelineFilters filters = const TimelineFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/timeline',
        queryParameters: {
          'subject_id': subjectId,
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (filters.types.isNotEmpty)
            'types': filters.types.map((type) => type.apiName).join(','),
          if (filters.from != null) 'from': _dateOnly(filters.from!),
          if (filters.to != null) 'to': _dateOnly(filters.to!),
          if (filters.tag.trim().isNotEmpty) 'tag': filters.tag.trim(),
          if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
        },
      );
      return TimelinePage.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

class TimelinePage {
  const TimelinePage({
    required this.results,
    required this.nextCursor,
    required this.previousCursor,
  });

  factory TimelinePage.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    return TimelinePage(
      results: results is List
          ? results
                .whereType<Map<String, dynamic>>()
                .map(MedicalEvent.fromJson)
                .toList(growable: false)
          : const <MedicalEvent>[],
      nextCursor: _cursorFromUrl(json['next']),
      previousCursor: _cursorFromUrl(json['previous']),
    );
  }

  final List<MedicalEvent> results;
  final String? nextCursor;
  final String? previousCursor;
}

String? _cursorFromUrl(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(value);
  return uri?.queryParameters['cursor'];
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

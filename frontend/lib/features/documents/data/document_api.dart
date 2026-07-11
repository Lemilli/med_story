import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/medical_document.dart';

final documentApiProvider = Provider<DocumentApi>((ref) {
  return DocumentApi(ref.watch(apiClientProvider));
});

class DocumentApi {
  const DocumentApi(this._dio);

  final Dio _dio;

  Future<DocumentStatusUpdate> createDocument(
    DocumentCreateRequest request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents',
        data: request.toJson(),
      );
      return DocumentStatusUpdate.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_create_failed');
    }
  }

  Future<DocumentStatusUpdate> ingestDocument({
    required String documentId,
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'mime_type': mimeType,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents/$documentId/ingest',
        data: formData,
      );
      return DocumentStatusUpdate.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_ingest_failed');
    }
  }

  Future<DocumentStatusUpdate> uploadAudio({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String title,
    String? subjectId,
    String? language,
    String? localUriHint,
    String? documentDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'mime_type': mimeType,
        'title': title,
        if (subjectId != null && subjectId.isNotEmpty) 'subject_id': subjectId,
        if (language != null && language.isNotEmpty) 'language': language,
        if (localUriHint != null && localUriHint.isNotEmpty)
          'local_uri_hint': localUriHint,
        if (documentDate != null && documentDate.isNotEmpty)
          'document_date': documentDate,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents/upload-audio',
        data: formData,
      );
      return DocumentStatusUpdate.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_audio_upload_failed');
    }
  }

  Future<DocumentPage> listDocuments({
    String? subjectId,
    DocumentType? docType,
    DocumentStatus? status,
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/documents',
        queryParameters: {
          'limit': limit,
          if (subjectId != null && subjectId.isNotEmpty)
            'subject_id': subjectId,
          if (docType != null) 'doc_type': docType.apiName,
          if (status != null) 'status': status.apiName,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return DocumentPage.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_list_failed');
    }
  }

  Future<MedicalDocument> getDocument(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/documents/$id');
      return MedicalDocument.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_load_failed');
    }
  }

  Future<DocumentExplanation> getDocumentExplanation(String documentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/documents/$documentId/explanation',
      );
      return DocumentExplanation.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      if (_isExplanationNotReady(error)) {
        throw const DocumentExplanationNotReady();
      }
      throw mapDioException(
        error,
        fallback: 'document_explanation_load_failed',
      );
    }
  }

  Future<ExplanationRegenerateResult> regenerateDocumentExplanation(
    String documentId,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents/$documentId/explanation/regenerate',
        data: const <String, dynamic>{},
      );
      return ExplanationRegenerateResult.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(
        error,
        fallback: 'document_explanation_regenerate_failed',
      );
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _dio.delete<void>('/documents/$id');
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_delete_failed');
    }
  }
}

class DocumentExplanationNotReady implements Exception {
  const DocumentExplanationNotReady();
}

class DocumentPage {
  const DocumentPage({
    required this.results,
    required this.nextCursor,
    required this.previousCursor,
  });

  factory DocumentPage.fromJson(Map<String, dynamic> json) {
    final data = json['results'];
    return DocumentPage(
      results: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(MedicalDocument.fromJson)
                .toList(growable: false)
          : const <MedicalDocument>[],
      nextCursor: _cursorFromUrl(json['next']),
      previousCursor: _cursorFromUrl(json['previous']),
    );
  }

  final List<MedicalDocument> results;
  final String? nextCursor;
  final String? previousCursor;
}

bool _isExplanationNotReady(DioException error) {
  if (error.response?.statusCode != 404) {
    return false;
  }
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) {
    return false;
  }
  final errorData = data['error'];
  if (errorData is Map<String, dynamic>) {
    return errorData['code'] == 'not_ready';
  }
  return data['code'] == 'not_ready';
}

String? _cursorFromUrl(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(value);
  return uri?.queryParameters['cursor'];
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/error/app_failure.dart';
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
        data: request.toJson()..removeWhere((_, value) => value == null),
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
    required List<({String path, String fileName, String mimeType})> files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      for (final file in files) {
        formData.files.add(
          MapEntry(
            files.length == 1 ? 'file' : 'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.fileName,
              contentType: DioMediaType.parse(file.mimeType),
            ),
          ),
        );
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents/$documentId/ingest',
        data: formData,
        onSendProgress: onSendProgress,
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
    void Function(int sent, int total)? onSendProgress,
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
        onSendProgress: onSendProgress,
      );
      return DocumentStatusUpdate.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_audio_upload_failed');
    }
  }

  Future<String> transcribeAudio({
    required String filePath,
    required String fileName,
    required String mimeType,
    String? language,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/capture/transcribe',
        data: FormData.fromMap({
          'mime_type': mimeType,
          if (language != null && language.isNotEmpty) 'language': language,
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        }),
      );
      final transcript = response.data?['transcript'];
      if (transcript is! String || transcript.trim().isEmpty) {
        throw const AppFailure('audio_unreadable');
      }
      return transcript.trim();
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'audio_unreadable');
    }
  }

  Future<DocumentStatusUpdate> processNote({
    required String text,
    String? subjectId,
    String? language,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/capture/notes',
        data: {
          'text': text,
          if (subjectId != null && subjectId.isNotEmpty)
            'subject_id': subjectId,
          if (language != null && language.isNotEmpty) 'language': language,
        },
      );
      return DocumentStatusUpdate.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'note_processing_failed');
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

  Future<void> deleteDocument(String id) async {
    try {
      await _dio.delete<void>('/documents/$id');
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'document_delete_failed');
    }
  }
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

String? _cursorFromUrl(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(value);
  return uri?.queryParameters['cursor'];
}

class AppFailure implements Exception {
  const AppFailure(this.message, {this.documentId});

  final String message;
  final String? documentId;

  @override
  String toString() => message;
}

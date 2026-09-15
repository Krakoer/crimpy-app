class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Whether the request never reached the server: no route to it, or no answer
  /// within the timeout. It says nothing about the app or the API being wrong,
  /// which is what tells it apart from every other failure here, so a caller
  /// can decline to report an athlete walking into a basement as a defect.
  final bool isOffline;

  ApiException(this.message, {this.statusCode, this.isOffline = false});

  @override
  String toString() => message;
}

/// Thrown by data sources when the API reports a failure. Data layer only.
class ServerException implements Exception {
  const ServerException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'ServerException($code, $message)';
}

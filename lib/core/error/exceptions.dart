class ServerException implements Exception {
  ServerException([this.message = 'Server error']);
  final String message;
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'Network error']);
  final String message;
}

class NotFoundException implements Exception {
  NotFoundException([this.message = 'Not found']);
  final String message;
}

class AuthException implements Exception {
  AuthException([this.message = 'Authentication error']);
  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error']);
  final String message;
}

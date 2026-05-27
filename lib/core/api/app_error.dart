import 'dart:io';

/// Classifies the type of error so the UI can render an appropriate message.
enum AppErrorType {
  /// No internet / DNS / socket failure.
  network,

  /// Server responded but returned an error (4xx / 5xx / bad payload).
  server,
}

/// Utility to classify any caught exception into an [AppErrorType].
class AppError {
  AppError._();

  /// Returns [AppErrorType.network] when [e] is a connectivity issue,
  /// [AppErrorType.server] for all other failures (HTTP errors, bad JSON, etc.).
  static AppErrorType classify(Object e) {
    if (e is SocketException) return AppErrorType.network;
    if (e is HandshakeException) return AppErrorType.network;
    // http package throws ClientException for low-level failures including
    // "Failed host lookup" which covers DNS / offline scenarios.
    if (e.toString().toLowerCase().contains('failed host lookup')) {
      return AppErrorType.network;
    }
    if (e.toString().toLowerCase().contains('socketexception')) {
      return AppErrorType.network;
    }
    if (e.toString().toLowerCase().contains('network is unreachable')) {
      return AppErrorType.network;
    }
    return AppErrorType.server;
  }
}

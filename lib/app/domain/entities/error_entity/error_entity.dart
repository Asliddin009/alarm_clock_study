import 'package:dio/dio.dart';

class ErrorEntity {
  final String message;
  final String? errorMessage;
  final dynamic error;
  final StackTrace? stackTrace;

  ErrorEntity({
    required this.message,
    this.errorMessage,
    this.error,
    this.stackTrace,
  });

  factory ErrorEntity.fromException(dynamic error) {
    if (error is ErrorEntity) return error;
    final entity = ErrorEntity(message: "Неизвестная ошибка");
    if (error is DioError) {
      try {
        return ErrorEntity(
            stackTrace: error.stackTrace,
            error: error,
            message: error.response?.data["message"] ?? "Неизвестная ошибка",
            errorMessage:
                error.response?.data["error"] ?? "Неизвестная ошибка");
      } catch (_) {
        return entity;
      }
    }
    return entity;
  }
}

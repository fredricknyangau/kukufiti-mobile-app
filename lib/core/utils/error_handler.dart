import 'package:dio/dio.dart';

/// Translates raw Exceptions (especially [DioException]) into user-friendly messages.
String getFriendlyErrorMessage(dynamic e) {
  if (e is DioException) {
    // 1. Check if the server returned detailed JSON data
    if (e.response?.data != null && e.response?.data is Map) {
      final errorData = e.response!.data as Map;
      final detail = errorData['detail'];

      if (detail != null) {
        // FastAPI sends "detail": "String msg" for standard HTTPExceptions
        if (detail is String) {
          return detail;
        }
        
        // FastAPI sends "detail": [{"msg": "...", ...}] for ValidationErrors (422)
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) {
            return first['msg'].toString();
          }
        }
      }
      
      // Fallback if detail key isn't formatted properly but something else exists
      if (errorData.containsKey('message')) {
        return errorData['message'].toString();
      }
    }

    // 2. Handle known HTTP status codes if no JSON detail exists
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Bad Request. Please check your inputs.';
        case 401:
          return 'Incorrect email or password.';
        case 403:
          return 'Access Denied: You do not have permission for this content.';
        case 404:
          return 'The requested resource was not found on the server.';
        case 429:
          return 'Too many requests. Please slow down and try again.';
        case 500:
          return 'Internal server error. Our team is looking into it.';
        case 503:
          return 'Service temporarily unavailable. Please try again soon.';
      }
    }

    // 3. Handle Dio-specific timeout/connection errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet speed.';
      case DioExceptionType.connectionError:
        return 'No internet connection or server is unreachable.';
      default:
        return e.message ?? 'An unexpected network error occurred.';
    }
  }

  // Fallback for general Dart exceptions (e.g., format exceptions, TypeErrors)
  final errString = e.toString();
  if (errString.contains('Exception:')) {
    return errString.replaceAll('Exception:', '').trim();
  }
  
  return 'An error occurred: $errString';
}

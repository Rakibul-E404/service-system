// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import '../../network/network_response_1.dart';
//
// class NetworkCaller {
//   // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
//   Future<NetworkResponse> _request(
//     String method,
//     String url, {
//     Map<String, dynamic>? body,
//     Map<String, String>? headers,
//     bool isLogin = false,
//   }) async {
//     final Uri uri = Uri.parse(url);
//     final Map<String, String> requestHeaders = <String, String>{
//       'Content-Type': 'application/json',
//       ...?headers,
//     };
//
//     try {
//       // Make the request using a single method instead of multiple ones.
//       Response response;
//       switch (method.toUpperCase()) {
//         case 'POST':
//           response = await post(
//             uri,
//             headers: requestHeaders,
//             body: jsonEncode(body),
//           );
//           break;
//         case 'GET':
//           response = await get(uri, headers: requestHeaders);
//           break;
//         case 'PUT':
//           response = await put(
//             uri,
//             headers: requestHeaders,
//             body: jsonEncode(body),
//           );
//           break;
//         case 'DELETE':
//           response = await delete(uri, headers: requestHeaders);
//           break;
//         case 'PATCH': // Add the PATCH case
//           response = await patch(
//             uri,
//             headers: requestHeaders,
//             body: jsonEncode(body),
//           );
//           break;
//         default:
//           throw Exception('Unsupported HTTP method: $method');
//       }
//
//       // Handle the response
//       return _handleResponse(response, isLogin);
//     } catch (e) {
//       debugPrint('Error: $e');
//       return NetworkResponse(isSuccess: false, errorMessage: e.toString());
//     }
//   }
//
//   // Handles response from the HTTP request and returns a NetworkResponse
//   NetworkResponse _handleResponse(Response response, bool isLogin) {
//     try {
//       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//
//       // Check if the response status is successful
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return NetworkResponse(
//           isSuccess: true,
//           jsonResponse: jsonResponse,
//           statusCode: response.statusCode,
//         );
//       }
//
//       // If status code is 401, it might be related to login, handle accordingly
//       if (response.statusCode == 401 && !isLogin) {
//         return NetworkResponse(
//           isSuccess: false,
//           statusCode: response.statusCode,
//           jsonResponse: jsonResponse,
//         );
//       }
//
//       // Handle unsuccessful responses
//       return NetworkResponse(
//         isSuccess: false,
//         statusCode: response.statusCode,
//         jsonResponse: jsonResponse,
//       );
//     } catch (e) {
//       return NetworkResponse(
//         isSuccess: false,
//         errorMessage: 'Error parsing response: ${e.toString()}',
//       );
//     }
//   }
//
//   // POST Request
//   Future<NetworkResponse> postRequest(
//     String url, {
//     Map<String, dynamic>? body,
//     bool isLogin = false,
//     Map<String, String>? headers,
//   }) async {
//     return _request(
//       'POST',
//       url,
//       body: body,
//       isLogin: isLogin,
//       headers: headers,
//     );
//   }
//
//   // GET Request
//   Future<NetworkResponse> getRequest(
//     String url, {
//     Map<String, dynamic>? body,
//     bool isLogin = false,
//     Map<String, String>? headers,
//   }) async {
//     return _request('GET', url, body: body, isLogin: isLogin, headers: headers);
//   }
//
//   // PUT Request
//   Future<NetworkResponse> putRequest(
//     String url, {
//     Map<String, dynamic>? body,
//     bool isLogin = false,
//     Map<String, String>? headers,
//   }) async {
//     return _request('PUT', url, body: body, isLogin: isLogin, headers: headers);
//   }
//
//   // DELETE Request
//   Future<NetworkResponse> deleteRequest(
//     String url, {
//     Map<String, dynamic>? body,
//     bool isLogin = false,
//     Map<String, String>? headers,
//   }) async {
//     return _request(
//       'DELETE',
//       url,
//       body: body,
//       isLogin: isLogin,
//       headers: headers,
//     );
//   }
//
//   // PATCH Request
//   Future<NetworkResponse> patchRequest(
//     String url, {
//     Map<String, dynamic>? body,
//     bool isLogin = false,
//     Map<String, String>? headers,
//   }) async {
//     return _request(
//       'PATCH',
//       url,
//       body: body,
//       isLogin: isLogin,
//       headers: headers,
//     );
//   }
// }





///
///======== todo:: trying with 'Dio' package========>
///


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../network/network_response.dart';

class NetworkCaller {
  late final Dio _dio;

  NetworkCaller() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE, PATCH)
  Future<NetworkResponse> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    try {
      // Merge custom headers with default headers
      final Map<String, dynamic> requestHeaders = {
        ..._dio.options.headers,
        ...?headers,
      };

      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;
        case 'GET':
          response = await _dio.get(
            url,
            options: Options(headers: requestHeaders),
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;
        case 'PATCH':
          response = await _dio.patch(
            url,
            data: body,
            options: Options(headers: requestHeaders),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle the response
      return _handleResponse(response, isLogin);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      return _handleDioError(e, isLogin);
    } catch (e) {
      debugPrint('Error: $e');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Handles successful response from the HTTP request
  NetworkResponse _handleResponse(Response response, bool isLogin) {
    try {
      final dynamic responseData = response.data;
      final Map<String, dynamic>? jsonResponse =
      responseData is Map<String, dynamic> ? responseData : null;

      // Check if the response status is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // If status code is 401, it might be related to login, handle accordingly
      if (response.statusCode == 401 && !isLogin) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
        );
      }

      // Handle unsuccessful responses
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // Handles Dio errors
  NetworkResponse _handleDioError(DioException error, bool isLogin) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Connection timeout',
        );
      case DioExceptionType.sendTimeout:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Send timeout',
        );
      case DioExceptionType.receiveTimeout:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Receive timeout',
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final jsonResponse = response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : null;

          // Handle 401 for non-login requests
          if (response.statusCode == 401 && !isLogin) {
            return NetworkResponse(
              isSuccess: false,
              statusCode: response.statusCode,
              jsonResponse: jsonResponse,
              errorMessage: 'Unauthorized',
            );
          }

          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
            errorMessage: 'Request failed with status: ${response.statusCode}',
          );
        }
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Bad response from server',
        );
      case DioExceptionType.cancel:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Request cancelled',
        );
      case DioExceptionType.connectionError:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'No internet connection',
        );
      case DioExceptionType.badCertificate:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: 'Bad certificate',
        );
      case DioExceptionType.unknown:
      default:
        return NetworkResponse(
          isSuccess: false,
          errorMessage: error.message ?? 'Unknown error occurred',
        );
    }
  }

  // POST Request
  Future<NetworkResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // GET Request
  Future<NetworkResponse> getRequest(
      String url, {
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'GET',
      url,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PUT Request
  Future<NetworkResponse> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PUT',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // DELETE Request
  Future<NetworkResponse> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'DELETE',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // PATCH Request
  Future<NetworkResponse> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request(
      'PATCH',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
    );
  }

  // Get Dio instance for advanced usage
  Dio get dio => _dio;
}
// class NetworkResponse {
//   final int? statusCode;
//
//   final bool isSuccess;
//
//   final Map<String, dynamic>? jsonResponse;
//
//   final String? errorMessage;
//
//   NetworkResponse({
//     this.statusCode,
//     required this.isSuccess,
//     this.jsonResponse,
//     this.errorMessage = 'Something went wrong',
//   });
// }






///
///======== todo:: trying with 'Dio' package========>
///



class NetworkResponse {
  final int? statusCode;
  final bool isSuccess;
  final Map<String, dynamic>? jsonResponse;
  final String? errorMessage;

  NetworkResponse({
    this.statusCode,
    required this.isSuccess,
    this.jsonResponse,
    this.errorMessage = 'Something went wrong',
  });

  // Helper method to check if response is successful
  bool get hasData => jsonResponse != null && jsonResponse!.isNotEmpty;

  // Helper method to get error message or default
  String get message => errorMessage ?? 'Something went wrong';

  // Helper method to get specific data from response
  T? getData<T>(String key) {
    if (jsonResponse == null) return null;
    return jsonResponse![key] as T?;
  }

  // Copy with method for immutability
  NetworkResponse copyWith({
    int? statusCode,
    bool? isSuccess,
    Map<String, dynamic>? jsonResponse,
    String? errorMessage,
  }) {
    return NetworkResponse(
      statusCode: statusCode ?? this.statusCode,
      isSuccess: isSuccess ?? this.isSuccess,
      jsonResponse: jsonResponse ?? this.jsonResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Convert to string for debugging
  @override
  String toString() {
    return 'NetworkResponse(statusCode: $statusCode, isSuccess: $isSuccess, errorMessage: $errorMessage, jsonResponse: $jsonResponse)';
  }

  // Factory constructor for error responses
  factory NetworkResponse.error({
    String? errorMessage,
    int? statusCode,
  }) {
    return NetworkResponse(
      isSuccess: false,
      errorMessage: errorMessage ?? 'Something went wrong',
      statusCode: statusCode,
    );
  }

  // Factory constructor for success responses
  factory NetworkResponse.success({
    required Map<String, dynamic> jsonResponse,
    int? statusCode,
  }) {
    return NetworkResponse(
      isSuccess: true,
      jsonResponse: jsonResponse,
      statusCode: statusCode ?? 200,
    );
  }
}
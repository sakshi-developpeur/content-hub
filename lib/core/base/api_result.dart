class Result<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool isSuccess;

  Result._({this.data, this.message, this.statusCode, required this.isSuccess});

  static Result<T> success<T>(T data) => Result._(data: data, isSuccess: true);

  static Result<T> failure<T>({
    required String message,
    int? statusCode,
    T? data,
  }) => Result._(
    message: message,
    statusCode: statusCode,
    isSuccess: false,
    data: data,
  );
}


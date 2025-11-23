sealed class ApiResponse<T> {}

class Idle<T> extends ApiResponse<T> {}

class Loading<T> extends ApiResponse<T> {}

class Success<T> extends ApiResponse<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends ApiResponse<T> {
  final String message;
  final Object? error;

  Failure(this.message, {this.error});
}

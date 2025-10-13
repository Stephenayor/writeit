class SigninState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  SigninState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  SigninState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return SigninState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

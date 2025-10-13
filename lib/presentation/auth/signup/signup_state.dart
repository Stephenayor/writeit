class SignupState {
  final String name;
  final String email;
  final String password;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final bool isPasswordVisible;

  SignupState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isPasswordVisible = false,
  });

  SignupState copyWith({
    String? name,
    String? email,
    String? password,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool? isPasswordVisible,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

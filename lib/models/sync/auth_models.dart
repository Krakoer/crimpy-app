import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
sealed class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
sealed class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
  }) = _AuthState;
}

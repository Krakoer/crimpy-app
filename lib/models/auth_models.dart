import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// ignore_for_file: invalid_annotation_target

@Freezed(toJson: true)
sealed class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstname,
    required String lastname,
    @JsonKey(name: 'email_verified') required bool emailVerified,
    @JsonKey(name: 'is_admin') @Default(false) bool isAdmin,
    @JsonKey(name: 'is_coach') @Default(false) bool isCoach,
    @JsonKey(name: 'coach_validated') @Default(false) bool coachValidated,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@Freezed(toJson: true)
sealed class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@Freezed(toJson: true)
sealed class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    @JsonKey(name: 'is_coach') @Default(false) bool isCoach,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@Freezed(toJson: true)
sealed class RegisterResponse with _$RegisterResponse {
  const factory RegisterResponse({
    required String message,
    required User user,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}

@Freezed(toJson: true)
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@Freezed(toJson: true)
sealed class VerifyEmailRequest with _$VerifyEmailRequest {
  const factory VerifyEmailRequest({required String token}) =
      _VerifyEmailRequest;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);
}

@Freezed(toJson: true)
sealed class ResendVerificationRequest with _$ResendVerificationRequest {
  const factory ResendVerificationRequest({required String email}) =
      _ResendVerificationRequest;

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationRequestFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstname: json['firstname'] as String,
  lastname: json['lastname'] as String,
  emailVerified: json['email_verified'] as bool,
  isAdmin: json['is_admin'] as bool? ?? false,
  isCoach: json['is_coach'] as bool? ?? false,
  coachValidated: json['coach_validated'] as bool? ?? false,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstname': instance.firstname,
  'lastname': instance.lastname,
  'email_verified': instance.emailVerified,
  'is_admin': instance.isAdmin,
  'is_coach': instance.isCoach,
  'coach_validated': instance.coachValidated,
  'created_at': instance.createdAt,
};

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      isCoach: json['is_coach'] as bool? ?? false,
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'is_coach': instance.isCoach,
    };

_RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    _RegisterResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseToJson(_RegisterResponse instance) =>
    <String, dynamic>{'message': instance.message, 'user': instance.user};

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
    };

_VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    _VerifyEmailRequest(token: json['token'] as String);

Map<String, dynamic> _$VerifyEmailRequestToJson(_VerifyEmailRequest instance) =>
    <String, dynamic>{'token': instance.token};

_ResendVerificationRequest _$ResendVerificationRequestFromJson(
  Map<String, dynamic> json,
) => _ResendVerificationRequest(email: json['email'] as String);

Map<String, dynamic> _$ResendVerificationRequestToJson(
  _ResendVerificationRequest instance,
) => <String, dynamic>{'email': instance.email};

_ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  _ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

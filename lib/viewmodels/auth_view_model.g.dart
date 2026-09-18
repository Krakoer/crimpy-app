// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  const ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'194a500119323a61b0fe18da62a65d2496a2025a';

/// Whether a user is signed in. Repositories watch this rather than the whole
/// auth state: it only changes when the user signs in or out, so refreshing the
/// profile no longer tears down and refetches every list in the app.

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Whether a user is signed in. Repositories watch this rather than the whole
/// auth state: it only changes when the user signs in or out, so refreshing the
/// profile no longer tears down and refetches every list in the app.

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a user is signed in. Repositories watch this rather than the whole
  /// auth state: it only changes when the user signs in or out, so refreshing the
  /// profile no longer tears down and refetches every list in the app.
  const IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'2a194a6c4ac56aa35a101cf7c8097a66a1bfa175';

/// Uploads guest-mode data to the API after a sign in.

@ProviderFor(localDataMigration)
const localDataMigrationProvider = LocalDataMigrationProvider._();

/// Uploads guest-mode data to the API after a sign in.

final class LocalDataMigrationProvider
    extends
        $FunctionalProvider<
          LocalDataMigration,
          LocalDataMigration,
          LocalDataMigration
        >
    with $Provider<LocalDataMigration> {
  /// Uploads guest-mode data to the API after a sign in.
  const LocalDataMigrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataMigrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataMigrationHash();

  @$internal
  @override
  $ProviderElement<LocalDataMigration> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalDataMigration create(Ref ref) {
    return localDataMigration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDataMigration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDataMigration>(value),
    );
  }
}

String _$localDataMigrationHash() =>
    r'86970a2fea7b7c5285b7a5bc4cfe012020b54d9c';

/// Persists the signed-in user on the device.

@ProviderFor(userRepository)
const userRepositoryProvider = UserRepositoryProvider._();

/// Persists the signed-in user on the device.

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// Persists the signed-in user on the device.
  const UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'6f33c0662d4bd5e514fd4f4f99ff0bcb31cd094d';

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  const AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'93c59e06939cae44bd06b13de59335959aa6ecc4';

@ProviderFor(AuthState)
const authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $AsyncNotifierProvider<AuthState, auth_models.User?> {
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  AuthState create() => AuthState();
}

String _$authStateHash() => r'c366340adfc8eaa674e68a07d26c64ea2526a4fe';

abstract class _$AuthState extends $AsyncNotifier<auth_models.User?> {
  FutureOr<auth_models.User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<auth_models.User?>, auth_models.User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<auth_models.User?>, auth_models.User?>,
              AsyncValue<auth_models.User?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

import 'package:crimpy/models/sync/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthModels', () {
    test('LoginRequest serializes to JSON correctly', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });

    test('LoginRequest deserializes from JSON correctly', () {
      final json = {'email': 'test@example.com', 'password': 'password123'};

      final request = LoginRequest.fromJson(json);

      expect(request.email, 'test@example.com');
      expect(request.password, 'password123');
    });

    test('RegisterRequest serializes with optional fields', () {
      final request = RegisterRequest(
        email: 'new@example.com',
        password: 'pass123',
        firstname: 'John',
        lastname: 'Doe',
      );

      final json = request.toJson();

      expect(json['email'], 'new@example.com');
      expect(json['password'], 'pass123');
      expect(json['firstname'], 'John');
      expect(json['lastname'], 'Doe');
    });

    test('AuthResponse deserializes with snake_case fields', () {
      final json = {'token': 'test_token_123', 'user_id': 'user_456'};

      final response = AuthResponse.fromJson(json);

      expect(response.token, 'test_token_123');
      expect(response.userId, 'user_456');
    });

    test('AuthState has correct default values', () {
      const state = AuthState();

      expect(state.isAuthenticated, false);
      expect(state.userId, null);
      expect(state.email, null);
      expect(state.firstname, null);
      expect(state.lastname, null);
    });
  });
}

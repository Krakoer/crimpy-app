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

    test('AuthResponse deserializes with nested user object', () {
      final json = {
        'message': 'Login successful',
        'token': 'test_token_123',
        'user': {
          'id': 'user_456',
          'email': 'test@example.com',
          'firstname': 'John',
          'lastname': 'Doe',
          'created_at': '2026-04-10 08:32:30.366837 +0000 UTC',
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.message, 'Login successful');
      expect(response.token, 'test_token_123');
      expect(response.user.id, 'user_456');
      expect(response.user.email, 'test@example.com');
      expect(response.user.firstname, 'John');
      expect(response.user.lastname, 'Doe');
      expect(response.user.createdAt, '2026-04-10 08:32:30.366837 +0000 UTC');
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

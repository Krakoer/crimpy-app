import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a denied sign in logs no password', () {
    expect(
      redactRequestBody({
        'email': 'climber@example.com',
        'password': 'hunter22',
      }),
      {'email': 'climber@example.com', 'password': '[REDACTED]'},
    );
  });

  test('a password change and a reset log none of their secrets', () {
    expect(
      redactRequestBody({
        'old_password': 'a',
        'new_password': 'b',
        'token': 'c',
        'refresh_token': 'd',
      }),
      {
        'old_password': '[REDACTED]',
        'new_password': '[REDACTED]',
        'token': '[REDACTED]',
        'refresh_token': '[REDACTED]',
      },
    );
  });

  test('a body that is not a map is logged as it is', () {
    expect(redactRequestBody('raw'), 'raw');
    expect(redactRequestBody([1, 2]), [1, 2]);
  });
}

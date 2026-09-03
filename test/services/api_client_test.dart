import 'package:crimpy/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The test binary carries no flavor and is not a release build, so it sees
  // the default every non-production build gets. Pinning it here is what stops
  // an edit to the stage logic from quietly pointing a debug run, or a beta APK
  // in a tester's hands, at the production database.
  test('the backend defaults away from production', () {
    expect(ApiClient.baseUrl, 'https://devapi.crimpy.app');
  });
}

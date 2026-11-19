import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/providers/fingerprint_service.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:flutter_template/views/access_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

/// Avoids the local_auth platform channel in tests.
class FakeLocalAuthentication extends LocalAuthentication {
  @override
  Future<bool> isDeviceSupported() async => false;
}

Future<void> pumpApp(WidgetTester tester, Map<String, String> storage) async {
  FlutterSecureStorage.setMockInitialValues(storage);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        fingerprintService: FingerprintService(
          localAuthentication: FakeLocalAuthentication(),
        ),
      ),
      child: const AppBootstrap(),
    ),
  );
  // Storage initialization + LoadingScreen delay.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  testWidgets('without a saved token the login page is shown', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, {'os': 'android', 'id': 'device-1'});

    expect(find.byType(AccessView), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('the login form validates its fields', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, {'os': 'android', 'id': 'device-1'});

    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Enter valid email'), findsOneWidget);
    expect(
      find.text('Password must be at least 7 characters long'),
      findsOneWidget,
    );
  });

  testWidgets('the saved language is used', (WidgetTester tester) async {
    await pumpApp(tester, {
      'os': 'android',
      'id': 'device-1',
      'language': 'it',
    });

    expect(find.text('Accedi'), findsOneWidget);
  });

  testWidgets('unsupported platforms show an error instead of crashing', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, {'os': 'linux', 'id': 'device-1'});

    expect(find.byType(AccessView), findsNothing);
    expect(find.textContaining('not supported'), findsOneWidget);
  });

  test('email validation', () {
    expect(AccessView.isValidEmail('name@example.com'), isTrue);
    expect(AccessView.isValidEmail('name@example'), isFalse);
    expect(AccessView.isValidEmail('not an email'), isFalse);
  });
}

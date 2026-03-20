import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapovana_mobile_app/features/auth/domain/entities/app_user.dart';
import 'package:tapovana_mobile_app/features/auth/domain/repos/auth_repository.dart';
import 'package:tapovana_mobile_app/main.dart';

// 1. Create a Fake Repository so the test doesn't actually call Firebase
class FakeAuthRepository implements AuthRepository {
  @override
  // Return an empty stream to simulate the initial checking state
  Stream<AppUser?> get user => const Stream.empty();

  @override
  Future<AppUser?> signInWithGoogle() async {
    return null; 
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // 2. Instantiate the fake repository
    final fakeAuthRepository = FakeAuthRepository();

    // 3. Build our app, passing in the required fake repository
    await tester.pumpWidget(MyApp(authRepository: fakeAuthRepository));

    // Trigger a frame and wait for any initial routing/animations to settle
    await tester.pumpAndSettle();

    // 4. Verify that the app successfully built the root MaterialApp
    // (We removed the old counter logic because your app no longer has a counter)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
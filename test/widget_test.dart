import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapovana_mobile_app/core/storage/secure_storage.dart';
import 'package:tapovana_mobile_app/features/auth/data/auth_api_repository.dart';
import 'package:tapovana_mobile_app/features/auth/data/firebase_auth_repo.dart';
import 'package:tapovana_mobile_app/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Create real instances (they won't actually call APIs in this test)
    final firebaseAuthRepo = FirebaseAuthRepository();
    final apiAuthRepo = AuthApiRepository();
    final secureStorage = SecureStorage();

    // Build the app with required parameters
    await tester.pumpWidget(MyApp(
      firebaseAuthRepo: firebaseAuthRepo,
      apiAuthRepo: apiAuthRepo,
      secureStorage: secureStorage,
    ));

    // Trigger a frame
    await tester.pump();

    // Verify the app built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slot11_smart_registration_app/main.dart';
import 'package:slot11_smart_registration_app/utils/validators.dart';

Future<void> fillForm(WidgetTester tester, String email, String confirm) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Vy');
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), '123456');
  await tester.enterText(fields.at(3), confirm);
}

void main() {
  test('Validators', () {
    expect(Validators.required('  '), isNotNull);
    expect(Validators.email('abc'), isNotNull);
    expect(Validators.email('a.b-c@mail.com'), isNull);
    expect(Validators.password('123'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });

  testWidgets('Empty form shows errors', (tester) async {
    await tester.pumpWidget(const SmartRegistrationApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Field is required'), findsNWidgets(2));
    expect(find.text('Email required'), findsOneWidget);
  });

  testWidgets('Confirm mismatch shows SnackBar', (tester) async {
    await tester.pumpWidget(const SmartRegistrationApp());
    await fillForm(tester, 'a@b.com', '654321');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('test@error.com shows service error, button hidden while loading',
      (tester) async {
    await tester.pumpWidget(const SmartRegistrationApp());
    await fillForm(tester, 'test@error.com', '123456');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // Đang loading → không còn nút để bấm lần 2
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Email already exists'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Valid form navigates to Success', (tester) async {
    await tester.pumpWidget(const SmartRegistrationApp());
    await fillForm(tester, 'a@b.com', '123456');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Registration Successful!'), findsOneWidget);
  });
}

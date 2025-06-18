// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studyvalue/main.dart';

void main() {
  testWidgets('StudyValue app starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: StudyValueApp(),
      ),
    );

    // Verify that our app shows the title
    expect(find.text('StudyValue'), findsOneWidget);

    // Verify that the main components are present
    expect(find.text('今日の獲得金額'), findsOneWidget);
    expect(find.text('現在の勉強時間'), findsOneWidget);
    expect(find.text('勉強開始'), findsOneWidget);
  });
}

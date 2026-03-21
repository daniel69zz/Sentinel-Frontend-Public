import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:test01/app.dart';

void main() {
  testWidgets('renders sentinel app', (WidgetTester tester) async {
    await tester.pumpWidget(const SentinelApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:test01/app.dart';

void main() {
  testWidgets('renders sentinel app', (WidgetTester tester) async {
    await tester.pumpWidget(const SentinelApp());

    expect(find.text('Ingresar'), findsWidgets);
  });
}

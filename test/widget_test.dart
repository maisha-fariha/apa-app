import 'package:apa/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('APA shell renders home donate CTA', (tester) async {
    await tester.pumpWidget(const ApaApp());
    await tester.pumpAndSettle();

    expect(find.text('DONATE'), findsOneWidget);
    expect(find.text('SUD, HAITI'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });
}

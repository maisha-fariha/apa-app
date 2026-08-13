import 'package:apa/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('APA shell renders home donate CTA', (tester) async {
    tester.view.physicalSize = const Size(390, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ApaApp());
    await tester.pump();

    expect(find.text('DONATE'), findsOneWidget);
    expect(find.text('SUD, HAITI'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('tablet landscape uses phone-style bottom nav without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ApaApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('DONATE'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('DONATION'), findsOneWidget);
  });
}

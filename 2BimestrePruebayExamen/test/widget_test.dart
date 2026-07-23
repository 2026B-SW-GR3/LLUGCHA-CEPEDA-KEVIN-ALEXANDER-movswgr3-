import 'package:flutter_test/flutter_test.dart';

import 'package:finalexamenyproyecto/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FitMapApp());
    expect(find.text('FitMap - Quedadas'), findsOneWidget);
  });
}

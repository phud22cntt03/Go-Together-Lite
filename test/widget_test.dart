//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_carpool_connect/main.dart';

void main() {
  testWidgets('App loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCarpoolApp());
    expect(find.text('Carpool'), findsOneWidget);
    expect(find.text('Kết nối mọi hành trình'), findsOneWidget);
  });
}
 
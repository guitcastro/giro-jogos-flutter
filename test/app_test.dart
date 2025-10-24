import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giro_jogos/src/app.dart';

void main() {
  testWidgets('GiroJogosApp has a title and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GiroJogosApp());

    // Verify that the app title is correct.
    expect(find.text('Welcome to Giro Jogos!'), findsOneWidget);
  });
}

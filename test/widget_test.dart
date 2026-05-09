import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// O nome no teu pubspec.yaml é 'jogo_forca'
import 'package:jogo_forca/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
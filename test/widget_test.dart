import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project_deep_learning/main.dart';

void main() {
  testWidgets('App launches and displays title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WasteClassificationApp());

    // Verify that our app displays the correct title
    expect(find.text('Waste Classifier'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}

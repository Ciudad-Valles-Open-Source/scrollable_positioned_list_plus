// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list_example/main.dart';

void _configureTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('Example Dashboard UI and Interactive Controls Tests', () {
    testWidgets('Verify AppBar header and professional status indicators',
        (WidgetTester tester) async {
      _configureTestView(tester);
      await tester.pumpWidget(const ScrollablePositionedListExample());
      await tester.pumpAndSettle();

      expect(find.text('ScrollablePositionedList Showcase'), findsOneWidget);
      expect(find.text('First Item: 0'), findsOneWidget);
      expect(find.text('Reversed: '), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('Verify offset scroll buttons displacement behavior',
        (WidgetTester tester) async {
      _configureTestView(tester);
      await tester.pumpWidget(const ScrollablePositionedListExample());
      await tester.pumpAndSettle();

      // Ensure item 0 is at top.
      expect(find.text('Item 0'), findsOneWidget);

      // Tap positive offset scroll button (+1000 pixels).
      final offsetButton1000 =
          find.byKey(const ValueKey<String>('ScrollOffset1000'));
      expect(offsetButton1000, findsOneWidget);
      await tester.tap(offsetButton1000);
      await tester.pumpAndSettle();

      // After shifting by 1000px downwards, item 0 should be out of viewport.
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('Verify list reversal functionality via interactive checkbox',
        (WidgetTester tester) async {
      _configureTestView(tester);
      await tester.pumpWidget(const ScrollablePositionedListExample());
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);

      // Tap the reversed checkbox.
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify list orientation reversed without layout error.
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Verify alignment control adjustment and instant jump behavior',
        (WidgetTester tester) async {
      _configureTestView(tester);
      await tester.pumpWidget(const ScrollablePositionedListExample());
      await tester.pumpAndSettle();

      // Adjust slider to change alignment.
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Perform Jump to index 100 with updated alignment.
      await tester.tap(find.byKey(const ValueKey<String>('Jump100')));
      await tester.pumpAndSettle();

      expect(find.text('Item 100'), findsOneWidget);
    });
  });
}

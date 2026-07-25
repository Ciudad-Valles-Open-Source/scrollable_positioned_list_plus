// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list_plus/scrollable_positioned_list_plus.dart';

const double _itemHeight = 50.0;
const double _screenHeight = 500.0;
const int _defaultItemCount = 1000;

void main() {
  group('ScrollablePositionedList Acceptance Tests', () {
    testWidgets(
        'Accurate programmatic navigation and position listener synchronization',
        (WidgetTester tester) async {
      final itemScrollController = ItemScrollController();
      final itemPositionsListener = ItemPositionsListener.create();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: _screenHeight,
              child: ScrollablePositionedList.builder(
                itemCount: _defaultItemCount,
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                itemBuilder: (context, index) => SizedBox(
                  height: _itemHeight,
                  child: Text('Item $index', key: ValueKey('item_$index')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial viewport rendering (indexes 0 to 9 should be visible).
      expect(find.byKey(const ValueKey('item_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_9')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_10')), findsNothing);

      final initialPositions = itemPositionsListener.itemPositions.value;
      expect(initialPositions.map((e) => e.index), containsAll([0, 9]));

      // Execute programmatic jump to index 150.
      itemScrollController.jumpTo(index: 150);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('item_0')), findsNothing);
      expect(find.byKey(const ValueKey('item_150')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_159')), findsOneWidget);

      final jumpedPositions = itemPositionsListener.itemPositions.value;
      expect(jumpedPositions.map((e) => e.index), contains(150));

      // Execute smooth animated scroll to index 500 with custom alignment.
      unawaited(itemScrollController.scrollTo(
        index: 500,
        alignment: 0.2,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('item_150')), findsNothing);
      expect(find.byKey(const ValueKey('item_500')), findsOneWidget);

      final scrolledPositions = itemPositionsListener.itemPositions.value;
      expect(scrolledPositions.map((e) => e.index), contains(500));
    });

    testWidgets('Boundary operations and dynamic dataset resizing behavior',
        (WidgetTester tester) async {
      final itemScrollController = ItemScrollController();
      final itemPositionsListener = ItemPositionsListener.create();
      int currentItemCount = 50;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    currentItemCount = 5;
                  });
                },
                child: const Icon(Icons.remove),
              ),
              body: SizedBox(
                height: _screenHeight,
                child: ScrollablePositionedList.builder(
                  itemCount: currentItemCount,
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemBuilder: (context, index) => SizedBox(
                    height: _itemHeight,
                    child: Text('Element $index',
                        key: ValueKey('element_$index')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Jump near the bottom boundary of the 50-item list.
      itemScrollController.jumpTo(index: 45);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('element_45')), findsOneWidget);

      // Trigger dynamic resizing of dataset down to 5 items while positioned near former end.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Ensure graceful adaptation without layout exceptions or overflow.
      expect(find.byKey(const ValueKey('element_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('element_4')), findsOneWidget);
      expect(find.byKey(const ValueKey('element_5')), findsNothing);
      expect(find.byKey(const ValueKey('element_45')), findsNothing);
    });

    testWidgets(
        'Offset control and precise scroll displacement verification',
        (WidgetTester tester) async {
      final scrollOffsetController = ScrollOffsetController();
      final scrollOffsetListener = ScrollOffsetListener.create();
      double totalScrolled = 0.0;

      scrollOffsetListener.changes.listen((offset) {
        totalScrolled += offset;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: _screenHeight,
              child: ScrollablePositionedList.builder(
                itemCount: 200,
                scrollOffsetController: scrollOffsetController,
                scrollOffsetListener: scrollOffsetListener,
                itemBuilder: (context, index) => SizedBox(
                  height: _itemHeight,
                  child: Text('Row $index'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(totalScrolled, equals(0.0));

      // Programmatically displace viewport by exact pixel amount.
      unawaited(scrollOffsetController.animateScroll(
        offset: 150.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      ));
      await tester.pumpAndSettle();

      // Ensure listener accumulated the scroll displacement accurately.
      expect(totalScrolled, moreOrLessEquals(150.0, epsilon: 1.0));
    });
  });
}

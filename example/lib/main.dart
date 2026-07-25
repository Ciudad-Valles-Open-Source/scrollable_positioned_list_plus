// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list_plus/scrollable_positioned_list_plus.dart';

const int numberOfItems = 5001;
const double minItemHeight = 40.0;
const double maxItemHeight = 150.0;
const Duration scrollDuration = Duration(seconds: 2);

void main() {
  runApp(const ScrollablePositionedListExample());
}

/// The root widget for the example application.
class ScrollablePositionedListExample extends StatelessWidget {
  const ScrollablePositionedListExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrollablePositionedList Demonstration',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      home: const ScrollablePositionedListPage(),
    );
  }
}

/// Interactive showcase for [ScrollablePositionedList].
///
/// Provides a dashboard interface with programmatic navigation controls:
/// - Animated scroll to specific item indexes with configurable alignment.
/// - Instantaneous jump to specific item indexes.
/// - Relative pixel displacement using offset controls.
/// - Real-time monitoring of visible viewport indices via position listeners.
class ScrollablePositionedListPage extends StatefulWidget {
  const ScrollablePositionedListPage({Key? key}) : super(key: key);

  @override
  State<ScrollablePositionedListPage> createState() =>
      _ScrollablePositionedListPageState();
}

class _ScrollablePositionedListPageState
    extends State<ScrollablePositionedListPage> {
  /// Controller to execute scrolls or jumps to a specific item index.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Controller to execute relative pixel scrolls from the current offset.
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();

  /// Listener that actively tracks item positions and visibility changes.
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late final List<double> itemHeights;
  late final List<Color> itemColors;
  bool reversed = false;

  /// Target alignment within the viewport for subsequent navigation operations.
  double alignment = 0;

  @override
  void initState() {
    super.initState();
    final heightGenerator = Random(328902348);
    final colorGenerator = Random(42490823);

    itemHeights = List<double>.generate(
      numberOfItems,
      (int _) =>
          heightGenerator.nextDouble() * (maxItemHeight - minItemHeight) +
          minItemHeight,
    );

    itemColors = List<Color>.generate(
      numberOfItems,
      (int _) {
        // Generate professional, balanced pastel and subdued hues.
        final int red = 100 + colorGenerator.nextInt(120);
        final int green = 120 + colorGenerator.nextInt(110);
        final int blue = 140 + colorGenerator.nextInt(115);
        return Color.fromARGB(255, red, green, blue);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ScrollablePositionedList Showcase',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 1,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) => Column(
          children: <Widget>[
            Expanded(
              child: list(orientation),
            ),
            _buildStatusPanel(theme),
            _buildControlPanel(theme),
          ],
        ),
      ),
    );
  }

  Widget list(Orientation orientation) => ScrollablePositionedList.builder(
        itemCount: numberOfItems,
        itemBuilder: (context, index) => item(index, orientation),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetController: scrollOffsetController,
        reverse: reversed,
        scrollDirection: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
      );

  Widget _buildStatusPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          int? min;
          int? max;
          if (positions.isNotEmpty) {
            min = positions
                .where((ItemPosition position) => position.itemTrailingEdge > 0)
                .reduce((ItemPosition min, ItemPosition position) =>
                    position.itemTrailingEdge < min.itemTrailingEdge
                        ? position
                        : min)
                .index;
            max = positions
                .where((ItemPosition position) => position.itemLeadingEdge < 1)
                .reduce((ItemPosition max, ItemPosition position) =>
                    position.itemLeadingEdge > max.itemLeadingEdge
                        ? position
                        : max)
                .index;
          }
          return Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'First Item: ${min ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Last Item: ${max ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Reversed: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Checkbox(
                value: reversed,
                onChanged: (bool? value) => setState(() {
                  if (value != null) {
                    reversed = value;
                  }
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          scrollControlButtons,
          const SizedBox(height: 6),
          scrollOffsetControlButtons,
          const SizedBox(height: 6),
          jumpControlButtons,
          const SizedBox(height: 8),
          alignmentControl,
        ],
      ),
    );
  }

  Widget get alignmentControl => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Alignment Control: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 240,
            child: SliderTheme(
              data: const SliderThemeData(
                showValueIndicator: ShowValueIndicator.onDrag,
              ),
              child: Slider(
                value: alignment,
                label: alignment.toStringAsFixed(2),
                onChanged: (double value) => setState(() => alignment = value),
              ),
            ),
          ),
        ],
      );

  Widget get scrollControlButtons => Row(
        children: <Widget>[
          const SizedBox(
            width: 130,
            child: Text(
              'Animated Scroll:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          scrollItemButton(0),
          scrollItemButton(5),
          scrollItemButton(10),
          scrollItemButton(100),
          scrollItemButton(1000),
          scrollItemButton(5000),
        ],
      );

  Widget get scrollOffsetControlButtons => Row(
        children: <Widget>[
          const SizedBox(
            width: 130,
            child: Text(
              'Offset Scroll (px):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          scrollOffsetButton(-1000),
          scrollOffsetButton(-100),
          scrollOffsetButton(-10),
          scrollOffsetButton(10),
          scrollOffsetButton(100),
          scrollOffsetButton(1000),
        ],
      );

  Widget get jumpControlButtons => Row(
        children: <Widget>[
          const SizedBox(
            width: 130,
            child: Text(
              'Instant Jump:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          jumpButton(0),
          jumpButton(5),
          jumpButton(10),
          jumpButton(100),
          jumpButton(1000),
          jumpButton(5000),
        ],
      );

  ButtonStyle _buttonStyle({required double horizontalPadding}) =>
      ButtonStyle(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        ),
        minimumSize: WidgetStateProperty.all(const Size(44, 36)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );

  Widget scrollItemButton(int value) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilledButton.tonal(
          key: ValueKey<String>('Scroll$value'),
          onPressed: () => scrollTo(value),
          style: _buttonStyle(horizontalPadding: 12),
          child: Text('$value'),
        ),
      );

  Widget scrollOffsetButton(int value) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: OutlinedButton(
          key: ValueKey<String>('ScrollOffset$value'),
          onPressed: () => scrollBy(value.toDouble()),
          style: _buttonStyle(horizontalPadding: 8),
          child: Text('$value'),
        ),
      );

  Widget jumpButton(int value) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ElevatedButton(
          key: ValueKey<String>('Jump$value'),
          onPressed: () => jumpTo(value),
          style: _buttonStyle(horizontalPadding: 12),
          child: Text('$value'),
        ),
      );

  void scrollTo(int index) => itemScrollController.scrollTo(
        index: index,
        duration: scrollDuration,
        curve: Curves.easeInOutCubic,
        alignment: alignment,
      );

  void scrollBy(double offset) => scrollOffsetController.animateScroll(
        offset: offset,
        duration: scrollDuration,
        curve: Curves.easeInOutCubic,
      );

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: alignment);

  /// Builds individual list elements with organized styling.
  Widget item(int i, Orientation orientation) {
    return SizedBox(
      height: orientation == Orientation.portrait ? itemHeights[i] : null,
      width: orientation == Orientation.landscape ? itemHeights[i] : null,
      child: Card(
        color: itemColors[i],
        child: Center(
          child: Text(
            'Item $i',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ),
    );
  }
}

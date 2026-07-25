# Scrollable Positioned List Plus for Flutter

A specialized Flutter widget that provides a scrollable list with direct navigation capabilities, enabling programmatic scrolling or immediate jumping to specific item indices regardless of viewport distance or intermediate layout state. Additionally, the library provides real-time tracking of item visibility and precise positional boundaries within the rendered viewport.

Based on: ([scrollable_positioned_list](https://github.com/google/flutter.widgets/tree/master/packages/scrollable_positioned_list))

## Overview and Architecture

Standard Flutter `ListView.builder` implementations construct only those child elements currently visible within or near the active viewport cache. While this architecture maximizes memory efficiency and rendering performance, it impedes direct navigation to distant indices because the physical dimensions and spatial offsets of intervening unbuilt widgets remain unknown.

`ScrollablePositionedList` solves this architectural limitation by decoupling index navigation from absolute pixel accumulation. It utilizes specialized bounding structures (`UnboundedCustomScrollView` and custom viewports) to render targets directly at specified viewport alignments, seamlessly managing transition states during long-distance animations without requiring complete intermediate widget instantiation.

## Features

- **Programmatic Navigation:** Jump immediately (`jumpTo`) or animate smoothly (`scrollTo`) to any item index with precise alignment control.
- **Visibility Monitoring:** Observe in real-time which list items are currently rendered inside the visible viewport and query their exact fractional leading and trailing edge boundaries using `ItemPositionsListener`.
- **Pixel Offset Displacement:** Perform relative pixel displacement adjustments from the current position using `ScrollOffsetController`.
- **Scroll Delta Tracking:** Monitor continuous scroll change delta events using `ScrollOffsetListener`.
- **Separated Builder Support:** Easily introduce custom separators between list items using `ScrollablePositionedList.separated`.
- **Modern SDK Compatibility:** Fully compatible with Dart 3.12+ and Flutter 3.22+ Material 3 environments, utilizing modern `ScrollCacheExtent` architecture without deprecated legacy member overrides.

## Installation

Add `scrollable_positioned_list_plus` to your project's `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  scrollable_positioned_list_plus: ^0.4.0
```

Execute `flutter pub get` in your terminal to fetch and link the package.

## Usage Guide

### Basic Initialization

Construct a `ScrollablePositionedList.builder` by attaching specialized controllers and listeners to observe and govern behavior:

```dart
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list_plus/scrollable_positioned_list_plus.dart';

class PositionedListDemonstration extends StatefulWidget {
  const PositionedListDemonstration({Key? key}) : super(key: key);

  @override
  State<PositionedListDemonstration> createState() => _PositionedListDemonstrationState();
}

class _PositionedListDemonstrationState extends State<PositionedListDemonstration> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();

  @override
  void initState() {
    super.initState();
    // Subscribe to item visibility changes
    itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  void _onPositionsChanged() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final firstVisible = positions
          .where((position) => position.itemTrailingEdge > 0)
          .reduce((min, position) => position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      debugPrint('Primary visible item index: $firstVisible');
    }
  }

  @override
  void dispose() {
    itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: 500,
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Item #$index', style: const TextStyle(fontSize: 16)),
        ),
      ),
      itemScrollController: itemScrollController,
      scrollOffsetController: scrollOffsetController,
      itemPositionsListener: itemPositionsListener,
      scrollOffsetListener: scrollOffsetListener,
    );
  }
}
```

### Separated List Initialization

To insert structural separating widgets (such as dividers or spacers) between primary items without manually altering index arithmetic, use `ScrollablePositionedList.separated`:

```dart
ScrollablePositionedList.separated(
  itemCount: 250,
  itemBuilder: (context, index) => ListTile(
    title: Text('Element #$index'),
  ),
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemScrollController: itemScrollController,
  itemPositionsListener: itemPositionsListener,
);
```

## Navigation Controls

### Animated Scrolling by Index

Invoke `scrollTo` on the `ItemScrollController` to transition smoothly to a specific target index over a specified duration:

```dart
if (itemScrollController.isAttached) {
  itemScrollController.scrollTo(
    index: 150,
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOutCubic,
    alignment: 0.0, // 0.0 positions target at viewport leading edge; 1.0 at trailing edge.
  );
}
```

### Instantaneous Jumping by Index

Invoke `jumpTo` to immediately re-render the viewport at the specified target index without intermediate animation frames:

```dart
if (itemScrollController.isAttached) {
  itemScrollController.jumpTo(
    index: 300,
    alignment: 0.5, // Centers the target item within the visible viewport.
  );
}
```

### Relative Pixel Displacement

To displace the scroll position by a specific pixel distance relative to the current offset:

```dart
scrollOffsetController.animateScroll(
  offset: 250.0, // Positive values scroll forward; negative values scroll backward.
  duration: const Duration(milliseconds: 500),
  curve: Curves.linear,
);
```

## Visibility Monitoring and Positional Metrics

The `ItemPositionsListener` exposes a value listenable returning an `Iterable<ItemPosition>`. Each `ItemPosition` structure encapsulates precise metrics:

- `index`: The integer index of the list item.
- `itemLeadingEdge`: The fractional position of the item's leading edge relative to the viewport leading boundary (`0.0` represents exact alignment with the start of the visible viewport).
- `itemTrailingEdge`: The fractional position of the item's trailing edge relative to the viewport start (`1.0` represents alignment with the trailing boundary of a viewport of standard length).

An item is partially or fully visible within the viewport whenever:
`position.itemTrailingEdge > 0.0 && position.itemLeadingEdge < 1.0`

## Testing and Verification

The repository incorporates automated unit, widget, and acceptance integration test suites designed for reliable execution across modern Flutter environments.

To execute the core unit and acceptance test suites:

```bash
flutter test
```

To execute the example application integration test suites:

```bash
cd example
flutter test
```

To perform static code analysis and linting verification across the project:

```bash
flutter analyze
```

## License and Disclaimer

This project is licensed under a BSD-style license. See the accompanying `LICENSE` file for definitive terms. Note: This library is an independent open-source contribution and is not an officially supported Google product.

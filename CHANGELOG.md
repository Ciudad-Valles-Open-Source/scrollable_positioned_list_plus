# 0.4.0
* **Package Renaming & Repository Relocation**: Renamed package to `scrollable_positioned_list_plus` and migrated repository URL to `https://github.com/Ciudad-Valles-Open-Source/scrollable_positioned_list_plus`. Provided backward-compatible export scaffolding (`lib/scrollable_positioned_list.dart`) while establishing `lib/scrollable_positioned_list_plus.dart` as the primary library entry point.
* **Environment & SDK Modernization**: Updated Dart SDK environment constraint to `^3.12.0` and aligned Flutter test configuration utilities with modern renderer standards (Flutter 3.22+ / Material 3). Removed obsolete `pedantic` dependency in favor of standard Dart analysis and `dart:async` utilities.
* **Complete Deprecation Eradication & Zero Warnings**:
  * Eradicated all instances of `// ignore: deprecated_member_use` by migrating `UnboundedCustomScrollView`, `UnboundedViewport`, `CustomShrinkWrappingViewport`, and associated custom rendering viewports from legacy `cacheExtent` / `cacheExtentStyle` properties to modern `ScrollCacheExtent` APIs (`scrollCacheExtent`).
  * Updated transform manipulations in `wrapping.dart` to use `transform.translateByDouble` to eliminate deprecation warnings from modern vector math matrices.
  * Corrected equality operator signature and type evaluation in `ItemPositionsListener.create()` (`operator ==(Object other)`).
  * Removed redundant non-null assertions and malformed template syntax across core classes (`ScrollablePositionedList`, `PositionedList`, and viewports) for strict analyzer compatibility.
* **Comprehensive Acceptance & Integration Testing**:
  * Migrated existing unit test suites (`scrollable_positioned_list_test.dart`, `positioned_list_test.dart`, `scroll_offset_listener_test.dart`) to native `dart:async` and modern `TestViewConfiguration` standards.
  * Added a dedicated acceptance test suite (`test/acceptance_test.dart`) verifying programmatic navigation accuracy, boundary edge cases, high-speed sequential jumps, and synchronous listener position reporting.
* **Example Application Refinement & UI/UX Audit**:
  * Redesigned the demonstration app in `example/lib/main.dart` with a clean Material 3 visual hierarchy, structured control dashboards, professional color palettes, and real-time status panels.
  * Resolved ambiguous widget keys in the example application (`ScrollOffset$value` vs `Scroll$value`) to prevent finder collisions during automated integration testing.
  * Introduced interactive widget and UI integration tests (`example/test/widget_test.dart`) validating button displacement, alignment adjustment slider behavior, and reverse orientation toggle functionality.
* **Documentation Standardization**: Restructured project documentation (`README.md`, `CHANGELOG.md`, and inline comments) with formal, technical English and complete absence of emojis or informal expressions.

# 0.3.8+1
* Migrate tests off deprecated APIs.
* Bump min Flutter version to 3.1.0.

# 0.3.8
* Add ScrollOffsetController to allow pixel-based changes in offset.
* Bump min sdk version to 2.15.0.

# 0.3.7
* Add ScrollOffsetListener to allow listening to changes in scroll offset.

# 0.3.6
* Fix cache extents for horizontal lists.
* scrollTo future doesn't complete until scrolling is done.

# 0.3.5
* Fix extraneous animation controller declaration in 0.3.4.

# 0.3.4
* Disposed the animation controller when disposing the scrollable list.

# 0.3.3
* Fix potential crash when reading from RenderBox.size.

# 0.3.2
* Re-apply Flutter framework bindings' null safety calls but set SDK constraints correctly to 2.12.0 instead.

# 0.3.1
* Reverts change from 0.3.0 where the Flutter version constraint should have been set to 2.12.0 instead of 2.10.5.

# 0.3.0
* Move to Flutter version 2.10.5 and update dependencies' null safety calls.

# 0.2.3
* Support shrink wrap.

# 0.2.2
* Move dependencies from pre-release versions to released versions.

# 0.2.1
* Fix crash on NaN or infinite offset.

# 0.2.0-nullsafety.0
* Update to null safety.

# 0.1.10
* Update the home page URL to fix [issue #190](https://github.com/google/flutter.widgets/issues/190).
* Miscellaneous tweaks to the example.
* Added documentation to address [issue #96](https://github.com/google/flutter.widgets/issues/96).
* Miscellaneous other cleanup.
* Restructured `_ScrollablePositionedListState` to try to simplify logic.
* Fixed an issue with `ItemScrollController.scrollTo` where it could scroll to the wrong item if a non-zero `alignment` was specified and if the list was manually scrolled by dragging.

# 0.1.9
* Fixed the example in `README.md`. Fixes [issue #191](https://github.com/google/flutter.widgets/issues/191).
* Made the example runnable with `flutter run`. Fixes [issue #211](https://github.com/google/flutter.widgets/issues/211).
* Updates to computation of semantic clip.
* Smoother transition between views on long scrolls.
* New controls over transition between views on long scrolls.

# 0.1.8
* Set updateScheduled to false when short circuiting due to empty list. To fix https://github.com/google/flutter.widgets/issues/182.

# 0.1.7
* Apply viewport dimensions in UnboundedRenderedViewport.performResize. To work around change in https://github.com/flutter/flutter/pull/61973 causing breakage.

# 0.1.6
* Change to do local scroll (without a fade) whenever target item is found within the cache.
* Added sdk constraints to the example.
* Moved `itemScrollControllerDetachment` to `_ScrollablePositionedListState.deactivate`.

# 0.1.5
* Added minCacheExtent to ScrollablePositionedList.
* Fixes the issue when item count updated from zero to one and `index` in `itemBuilder` becomes `-1`. Fixes [issue #104](https://github.com/google/flutter.widgets/issues/104).

# 0.1.4
* itemBuilders should not be called with indices > itemCount - 1. Fixes [issue #42](https://github.com/google/flutter.widgets/issues/42) and [issue #77](https://github.com/google/flutter.widgets/issues/77).

# 0.1.3
* Don't build items when `itemCount` is 0. Fixes [issue #78](https://github.com/google/flutter.widgets/issues/78).
* Fix typos in `README.md`.

# 0.1.2
* Store scroll state in page storage to fix [issue #43](https://github.com/google/flutter.widgets/issues/43).

# 0.1.1
* Fix padding for horizontal lists.
* Add `ScrollablePositionedList.separated` constructor to complete [issue #34](https://github.com/google/flutter.widgets/issues/34).
* Add `isAttached` method to `ItemScrollController`.

# 0.1.0
* Properly bound `ScrollablePositionedList` to fix [issue #23](https://github.com/google/flutter.widgets/issues/23).
* Allow `ScrollablePositionedList` alignment outside `[0..1]` to fix [issue #31](https://github.com/google/flutter.widgets/issues/31).
* Moved `ScrollablePositionedList` example into `example` subdirectory.

# 0.0.1
* Added `ScrollablePositionedList`.

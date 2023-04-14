// ignore_for_file: unused_element

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/snapshot.dart' as snapshot_file show snapshot;

class Spot with CommonSpots<Widget> {
  @override
  WidgetSelector? get _self => null;
}

Type _typeOf<T>() => T;

PropMatcher<Text> hasText(String text) {
  return PropMatcher<Text>(
    (it) => it.hasText(text),
    description: 'hasText($text)',
  );
}

PropMatcher<Container> hasColor(Color color) {
  return PropMatcher<Container>(
    (it) => it.widget.color == color,
    description: 'hasColor($color)',
  );
}

extension TextWidgetSelector on WidgetMatcher<Text> {
  WidgetMatcher<Text> hasText(String text) {
    if (widget.data != text) {
      throw TestFailure(
        'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
      );
    }
    return this;
  }

  WidgetMatcher<Text> containsText(String text) {
    if (widget.data != text) {
      throw TestFailure(
        'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
      );
    }
    return this;
  }

  WidgetMatcher<Text> hasMaxLines(int? maxLines) {
    if (widget.maxLines != maxLines) {
      throw TestFailure(
        'Expected to find text with maxLines "$maxLines" but found "${widget.maxLines}" at ${selector.toStringBreadcrumb()}',
      );
    }
    // final elements = this.elements;
    // for (final element in elements) {
    //   final textWidget = element.widget as Text;
    //   if (textWidget.data != text) {
    //     throw TestFailure(
    //       'Expected to find text "$text" but found "${textWidget.data}" at ${toStringBreadcrumb()}',
    //     );
    //   }
    // }
    return this;
  }
}

// PropMatcher<Text> withText(String text) {
//   return (w) => w.hasText(text);
// }

class WidgetMatcher<W extends Widget> {
  W get widget => element.widget as W;
  final Element element;
  final WidgetSelector selector;

  WidgetMatcher({
    required this.element,
    required this.selector,
  }) : assert(element.widget is W);
}

class PropMatcher<W extends Widget> {
  final void Function(WidgetMatcher<W>) matcher;
  final String description;

  const PropMatcher(
    this.matcher, {
    required this.description,
  });
}

// typedef PropSelector<W extends Widget> = void Function(WidgetSelector<W>);

mixin CommonSpots<T extends Widget> {
  WidgetSelector<T>? get _self;

  WidgetSelector<W> byType<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],

    // TODO decide which one is better
    void Function(WidgetMatcher<W>)? propsFn,
    List<PropMatcher<W>> propsList = const [],
  }) {
    final type = _typeOf<W>();
    final selector = WidgetSelector<W>._(
      query: ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      parents: [if (_self != null) _self!, ...parents],
      children: children,
      props: propsFn,
    );

    return selector;
  }

  WidgetSelector<W> constrain<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    // Very, very experimental, not likely to stay
    // List<WidgetProp> props = const [],
    List<void Function(WidgetSelector<W>)> props = const [],
  }) {
    final type = _typeOf<W>();
    return WidgetSelector<W>._(
      query: ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  WidgetSelector<W> byWidget<W extends Widget>(W widget) {
    return WidgetSelector<W>._(
      query: ElementTreeQuery(
        (Element e) => e.widget == widget,
        description: 'Widget matches $widget',
      ),
    );
  }

  WidgetSelector<W> byElement<W extends Widget>(Element element) {
    return WidgetSelector<W>._(
      query: ElementTreeQuery(
        (Element e) => e == element,
        description: 'Element matches $element',
      ),
    );
  }

  WidgetSelector childByType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      query: ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  WidgetSelector childByWidgetPredicate(
    ElementTreeQuery predicate, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      query: predicate,
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  WidgetSelector childByElementType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      query: ElementTreeQuery(
        (Element e) => e.runtimeType == type,
        description: 'Element of type $type',
      ),
      parents: [
        if (_self != null) _self!,
        ...parents,
      ],
      children: children,
    );
  }

  WidgetSelector text(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return WidgetSelector._(
      query: ElementTreeQuery(
        (Element e) {
          if (e.widget is Text) {
            return (e.widget as Text).data == text;
          }
          if (e.widget is EditableText) {
            return (e.widget as EditableText).controller.text == text;
          }
          if (findRichText == true && e.widget is RichText) {
            return (e.widget as RichText).text.toPlainText() == text;
          }
          return false;
        },
        description: 'Widget with exact text: "$text"',
      ),
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  // /// Caution: this is a very expensive operation.
  // WidgetSelector childWidgetWithText(
  //   Type widgetType,
  //   String text, {
  //   bool skipOffstage = true,
  //   List<WidgetSelector> parents = const [],
  //   List<WidgetSelector> children = const [],
  // }) {
  //   final finder = find.widgetWithText(
  //     widgetType,
  //     text,
  //     skipOffstage: skipOffstage,
  //   );
  //   return WidgetSelector._(
  //     finder,
  //     [if (_self != null) _self!, ...parents],
  //     children,
  //   );
  // }

  // WidgetSelector textContaining(
  //   Pattern pattern, {
  //   bool skipOffstage = true,
  //   List<WidgetSelector> parents = const [],
  //   List<WidgetSelector> children = const [],
  // }) {
  //   final finder = find.textContaining(
  //     pattern,
  //     skipOffstage: skipOffstage,
  //   );
  //   return WidgetSelector._(
  //     finder,
  //     [if (_self != null) _self!, ...parents],
  //     children,
  //   );
  // }
  //
  WidgetSelector childByIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      query: ElementTreeQuery(
        (Element e) {
          if (e.widget is Icon) {
            return (e.widget as Icon).icon == icon;
          }
          return false;
        },
        description: 'Widget with icon: "$icon"',
      ),
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }
//
// WidgetSelector child(
//   Finder finder, {
//   List<WidgetSelector> parents = const [],
//   List<WidgetSelector> children = const [],
// }) {
//   return WidgetSelector._(
//     finder,
//     [if (_self != null) _self!, ...parents],
//     children,
//   );
// }
}

extension SpotFinder on Finder {
  WidgetSelector get spot {
    return WidgetSelector._(
      query: ElementTreeQuery(
        (e) => evaluate().contains(e),
        description: 'Finder: $description',
      ),
    );
  }
}

class ElementTreeQuery {
  final bool Function(Element) predicate;
  final String description;

  ElementTreeQuery(this.predicate, {required this.description});
}

class DirectionalElementTreeQuery extends ElementTreeQuery
    implements DirectionalQuery {
  @override
  final Direction direction;

  DirectionalElementTreeQuery(
    super.predicate, {
    required this.direction,
    required super.description,
  });
}

abstract class DirectionalQuery {
  Direction get direction;
}

enum Direction {
  parent,
  child,
}

/// A [WidgetSelector] that only ever matches a single widget
class SingleWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  SingleWidgetSelector._({
    required super.query,
    super.parents,
    super.children,
    super.props,
  }) : super._(matchesSingleWidget: true);

  SpotSnapshot<W> call() {
    return snapshot_file.snapshot(this);
  }
}

class MultiWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  MultiWidgetSelector._({
    required super.query,
    super.parents,
    super.children,
    super.props,
  }) : super._(matchesSingleWidget: false);

  SpotSnapshot<W> call() {
    return snapshot_file.snapshot(this);
  }
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with CommonSpots<W> {
  static final WidgetSelector all = WidgetSelector._(
    query: ElementTreeQuery(
      (e) => true,
      description: 'Root',
    ),
  );

  WidgetSelector._({
    required this.query,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    this.props,
    this.matchesSingleWidget,
  })  : parents = parents ?? [],
        children = children ?? [];

  final List<WidgetSelector> parents;
  final List<WidgetSelector> children;

  // TODO combine?
  final ElementTreeQuery query;
  void Function(WidgetMatcher<W>)? props;

  /// True when this selector should only match a single widget
  final bool? matchesSingleWidget;

  @override
  String toString() {
    final children = this.children.isNotEmpty
        ? 'children: [${this.children.map((e) => e.toString()).join(', ')}]'
        : null;
    final parents = this.parents.isNotEmpty
        ? 'parents: [${this.parents.map((e) => e.toString()).join(', ')}]'
        : null;
    // TODO make prop matchers printable
    // final props = this.props.isNotEmpty
    //     ? 'props: [${this.props.map((e) => e.toString()).join(', ')}]'
    //     : null;

    if (this.children.isEmpty && this.parents.isEmpty) {
      return "'${query.description}'";
    }

    final constraints = [children, parents, props].where((e) => e != null);
    return "'${query.description} with ${constraints.join(', ')}'";
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      return query.description;
    }
    final parentBreadcrumbs = parents.map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return '${parentBreadcrumbs.first} > ${toString()}';
    } else {
      return '[${parentBreadcrumbs.join(' && ')}] > ${toString()}';
    }
  }

  @override
  WidgetSelector<W> get _self => this;

  WidgetSelector<W> copyWith({
    ElementTreeQuery? query,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    void Function(WidgetMatcher<W>)? props,
    bool? single,
  }) {
    return WidgetSelector<W>._(
      query: query ?? this.query,
      parents: parents ?? this.parents,
      children: children ?? this.children,
      props: props ?? this.props,
      matchesSingleWidget: single ?? this.matchesSingleWidget,
    );
  }
}

/// An [Element] in the widget tree that was found with a [WidgetSelector] query
class SpotNode<W extends Widget> {
  /// The parent node from where the node has been found
  final SpotNode? parent;

  /// The selector that has been used to find [value]
  final WidgetSelector<W> selector;

  /// The element that has been found
  final Element value;

  /// All candidates that have been checked with [selector]
  final List<Element> candidates;

  /// All [candidates] that match the [WidgetSelector.children] constraints
  final List<Element>? matchesChildren;

  /// All [candidates] that match the [WidgetSelector.props] constraints
  final List<Element>? matchesProps;

  /// All [candidates] that match the [WidgetSelector.parents] constraints
  final List<Element>? matchesParents;

  const SpotNode({
    required this.parent,
    required this.selector,
    required this.value,
    required this.candidates,
    this.matchesChildren,
    this.matchesProps,
    this.matchesParents,
  });

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType{value: ${value.widget.toStringShallow()}, parent: ${parent?.value.toStringShort()}}';
  }
}

class SpotSnapshot<W extends Widget> {
  final WidgetSelector<W> selector;

  final List<SpotNode<W>> discovered;

  final List<Element> candidates;

  final Map<WidgetSelector, List<SpotNode>> searchResults;

  List<W> get matches => discovered.map((e) => e.value.widget as W).toList();

  List<Element> get matchingElements => discovered.map((e) => e.value).toList();

  SpotSnapshot({
    required this.selector,
    required this.searchResults,
    required this.discovered,
    required this.candidates,
  }) {
    // matches = searchResults.values.map((e) => e.actual!.widget as W).toList();
    // matchingElements = searchResults.values.map((e) => e.actual!).toList();
  }

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${matchingElements.length} matches)}';
  }
}

extension SnapshotSelector<W extends Widget> on WidgetSelector<W> {
  SpotSnapshot snapshot() {
    return snapshot_file.snapshot(this);
  }

  MultiWidgetSelector<W> get multi {
    return MultiWidgetSelector<W>._(
      query: query,
      parents: parents,
      children: children,
      props: props,
    );
  }

  SpotSnapshot<W> existsOnce() {
    return single().existsOnce();
  }

  void doesNotExist() {
    final snapshot = this.snapshot();
    if (snapshot.discovered.isNotEmpty) {
      throw Exception(
          'Expected no matches for $this, but found ${snapshot.discovered.length} matches');
    }
  }

  MultiWidgetSelector<W> existsAtLeastOnce() {
    return multi;
  }

  SingleWidgetSelector<W> get single {
    return SingleWidgetSelector<W>._(
      query: query,
      parents: parents,
      children: children,
      props: props,
    );
  }
}

//
// class _MultiAncestorDescendantFinder extends Finder {
//   _MultiAncestorDescendantFinder(
//     this.ancestors,
//     this.finder, {
//     super.skipOffstage,
//   });
//
//   final List<Finder> ancestors;
//   final Finder finder;
//
//   @override
//   String get description {
//     return '${finder.description} that has ancestors with [${ancestors.map((e) => e.description).join(' && ')}]';
//   }
//
//   @override
//   Iterable<Element> apply(Iterable<Element> candidates) {
//     final evaluate = finder.evaluate().toSet();
//     return candidates.where((Element element) => evaluate.contains(element));
//   }
//
//   @override
//   Iterable<Element> get allCandidates sync* {
//     if (ancestors.isEmpty) {
//       yield* super.allCandidates;
//       return;
//     }
//     final List<Set<Element>> ancestorElements = ancestors.map((ancestor) {
//       return ancestor.evaluate().expand((element) {
//         return collectAllElementsFrom(element, skipOffstage: skipOffstage);
//       }).toSet();
//     }).toList();
//
//     // find elements that are in all iterables
//     final firstList = ancestorElements.removeAt(0);
//     for (final element in firstList) {
//       bool allMatch = true;
//       for (final ancestorElements in ancestorElements) {
//         if (!ancestorElements.contains(element)) {
//           allMatch = false;
//           break;
//         }
//       }
//       if (allMatch) {
//         // element in all ancestors
//         yield element;
//       }
//     }
//   }
// }
//
// class _MultiDescendantsAncestorFinder extends Finder {
//   _MultiDescendantsAncestorFinder(this.descendants, this.finder)
//       : super(skipOffstage: false);
//
//   final Finder finder;
//   final List<Finder> descendants;
//
//   @override
//   String get description {
//     return '${finder.description} which is an ancestor of  [${descendants.map((e) => e.description).join(' && ')}]';
//   }
//
//   @override
//   Iterable<Element> apply(Iterable<Element> candidates) {
//     final allPossible = finder.evaluate().toSet();
//     return candidates.where((Element element) => allPossible.contains(element));
//   }
//
//   @override
//   Iterable<Element> get allCandidates {
//     if (descendants.isEmpty) {
//       return super.allCandidates;
//     }
//     final Iterable<Element> possibleParents = descendants.expand((ancestor) {
//       return ancestor.evaluate().expand((element) {
//         return element.parents.toList();
//       });
//     });
//
//     return possibleParents;
//   }
// }

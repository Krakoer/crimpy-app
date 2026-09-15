import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags the three ways of reading an [AsyncValue] that throw away the value it
/// is still holding.
///
/// A provider rebuilt because one of its dependencies was invalidated is a
/// reload, not a fresh load: the new state is an `AsyncLoading` carrying the
/// previous value, and a failure is an `AsyncError` carrying it too. Anything
/// that invalidates a provider under a screen the athlete is reading, which is
/// every pull to refresh, therefore empties any widget that reads it through:
///
///   - `.asData`, which is null on both;
///   - an `AsyncData(...)`, `AsyncError(...)` or `AsyncLoading(...)` pattern,
///     which matches on the state's type rather than on what it holds;
///   - `when`, `maybeWhen` or `whenOrNull` without `skipLoadingOnReload: true`
///     and `skipError: true`, which both default to false;
///   - `map`, `maybeMap`, `mapOrNull` and `whenData`, which dispatch on the
///     state's type and take no flag that would stop them;
///   - `is AsyncData<T>`, which is the pattern form without the pattern.
///
/// Read `value` instead, or match `AsyncValue(:final value?)` and
/// `AsyncValue(:final error?)`, or pass both skip flags. Where the blanking is
/// wanted, `// ignore` it and say why: a run screen that must not show stale
/// numbers is a real case.
///
/// The rule does not try to work out whether a given read is downstream of a
/// pull. That question is global and the answer changes whenever a provider
/// gains a dependency, which is exactly how five review rounds each found a
/// site the last one had not.
class KeepTheHeldValue extends DartLintRule {
  const KeepTheHeldValue() : super(code: _code);

  static const _code = LintCode(
    name: 'keep_the_held_value',
    problemMessage:
        'This drops the value the state is still holding, so the widget empties '
        'itself while the provider reloads and stays empty if the reload fails.',
    correctionMessage:
        'Read `value`, or match `AsyncValue(:final value?)` and '
        '`AsyncValue(:final error?)`, or pass skipLoadingOnReload: true and '
        'skipError: true.',
  );

  static const _asyncValueNames = {
    'AsyncValue',
    'AsyncData',
    'AsyncError',
    'AsyncLoading',
  };

  static bool _isAsyncValue(DartType? type) {
    if (type is! InterfaceType) return false;
    for (final t in [type, ...type.allSupertypes]) {
      if (_isRiverpodState(t)) return true;
    }
    return false;
  }

  /// Riverpod's own, and not something else wearing the name: `dart:async` has
  /// an `AsyncError` of its own, and destructuring one in a stream handler has
  /// nothing to do with a widget emptying itself.
  static bool _isRiverpodState(InterfaceType type) =>
      _asyncValueNames.contains(type.element.name) &&
      (type.element.library.uri.toString().startsWith('package:riverpod/'));

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    // `x.asData`, whose whole purpose is to answer null unless the state is
    // exactly AsyncData.
    context.registry.addPropertyAccess((node) {
      if (node.propertyName.name != 'asData') return;
      if (!_isAsyncValue(node.realTarget.staticType)) return;
      reporter.atNode(node.propertyName, _code);
    });
    context.registry.addPrefixedIdentifier((node) {
      if (node.identifier.name != 'asData') return;
      if (!_isAsyncValue(node.prefix.staticType)) return;
      reporter.atNode(node.identifier, _code);
    });

    // A state-typed pattern, which is a test of what the state is where what
    // was meant was a test of what it holds.
    context.registry.addObjectPattern((node) {
      final name = node.type.name.lexeme;
      if (!_statePatterns.contains(name)) return;
      if (!_isAsyncValue(node.type.type)) return;
      // An error or loading arm under an arm that already took every state
      // holding a value only ever runs with nothing held, so it drops nothing.
      if (name != 'AsyncData' && _underAnArmTakingTheValue(node)) return;
      reporter.atNode(node.type, _code);
    });

    // `state is AsyncData<T>`, which tests what the state is without being a
    // pattern at all, and is the same mistake one keystroke shorter.
    context.registry.addIsExpression((node) {
      final type = node.type.type;
      if (type is! InterfaceType) return;
      if (!_statePatterns.contains(type.element.name)) return;
      if (!_isRiverpodState(type)) return;
      if (!_isAsyncValue(node.expression.staticType)) return;
      reporter.atNode(node.type, _code);
    });

    // `final AsyncData<T> d =>`, which is the same type test as `is`, written
    // as a pattern that binds rather than as one that destructures.
    context.registry.addDeclaredVariablePattern(
      (node) => _reportTypedPattern(reporter, node, node.type),
    );

    // `case AsyncData<T> _`, the same test again with the binding left out.
    context.registry.addWildcardPattern(
      (node) => _reportTypedPattern(reporter, node, node.type),
    );

    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      final needsFlags = _flaggable.contains(name);
      if (!needsFlags && !_unflaggable.contains(name)) return;
      if (!_isAsyncValue(node.realTarget?.staticType)) return;
      if (needsFlags &&
          _passesTrue(node, 'skipLoadingOnReload') &&
          _passesTrue(node, 'skipError')) {
        return;
      }
      reporter.atNode(node.methodName, _code);
    });
  }

  /// The patterns that match on which state it is.
  static const _statePatterns = {'AsyncData', 'AsyncError', 'AsyncLoading'};

  /// The readers that keep the value when told to.
  static const _flaggable = {'when', 'maybeWhen', 'whenOrNull'};

  /// The readers that dispatch on the state's type and take no flag that would
  /// stop them, so there is no spelling of these that keeps the value.
  static const _unflaggable = {
    'map',
    'maybeMap',
    'mapOrNull',
    'whenData',
    // Its documented purpose: reverting to the raw state with no information
    // about the previous one. It is the one call whose whole job is this bug,
    // and it poisons the reads this rule recommends, since what it hands back
    // makes `AsyncValue(:final value?)` see nothing.
    'unwrapPrevious',
  };

  /// Whether an earlier arm of the same switch has already taken every state
  /// that holds a value, which is what leaves this one nothing to drop.
  ///
  /// Only a switch, and only an arm of it. Switch arms are exclusive, so an
  /// earlier one really does mean this one did not run; sibling `if` statements
  /// are not, and reading them as arms is how the rule waved through the very
  /// bug it exists to stop. A correct if-case chain carries an ignore instead.
  ///
  /// The node must be the arm's own pattern, not something nested in its body:
  /// a switch over one provider says nothing about a state read inside it.
  static bool _underAnArmTakingTheValue(AstNode node) {
    final guarded = node.thisOrAncestorOfType<GuardedPattern>();
    if (guarded == null) return false;
    final cases = switch (guarded.parent?.parent) {
      SwitchExpression(:final cases) => cases.map((c) => c.guardedPattern),
      SwitchStatement(:final members) =>
        members.whereType<SwitchPatternCase>().map((c) => c.guardedPattern),
      _ => null,
    };
    if (cases == null) return false;
    for (final earlier in cases) {
      if (earlier.pattern.offset >= guarded.pattern.offset) break;
      if (_takesEveryHeldValue(earlier)) return true;
    }
    return false;
  }

  static bool _takesEveryHeldValue(GuardedPattern guarded) {
    if (guarded.whenClause != null) return false;
    return _patternTakesEveryHeldValue(guarded.pattern);
  }

  /// Whether a pattern matches every state that is carrying a value.
  ///
  /// Two spellings do: binding `value` under a null check, and asking for
  /// `hasValue: true`, which is the one a nullable-valued provider needs since
  /// a null check cannot tell "resolved to null" from "nothing yet".
  static bool _patternTakesEveryHeldValue(DartPattern pattern) {
    final bare = pattern is ParenthesizedPattern ? pattern.pattern : pattern;
    if (bare is! ObjectPattern) return false;
    final type = bare.type.type;
    if (type is! InterfaceType) return false;
    if (type.element.name != 'AsyncValue' || !_isRiverpodState(type)) {
      return false;
    }
    // One field has to prove it holds a value, and none of the others may
    // narrow which states match. `AsyncValue(:final value?, :final error?)`
    // takes only the states holding both, so a plain reload falls past it and
    // blanks in the arm below; `AsyncValue(:final value, hasValue: true)` binds
    // without narrowing and takes every one of them.
    var proven = false;
    for (final field in bare.fields) {
      if (_provesAValueIsHeld(field)) {
        proven = true;
        continue;
      }
      if (!_bindsWithoutNarrowing(field.pattern)) return false;
    }
    return proven;
  }

  static bool _provesAValueIsHeld(PatternField field) {
    final name = _fieldName(field);
    if (name == 'value') return field.pattern is NullCheckPattern;
    return name == 'hasValue' && field.pattern.toSource().trim() == 'true';
  }

  /// Whether a field's pattern matches whatever it is given. An untyped binding
  /// and a wildcard do; anything that can decline narrows the arm.
  static bool _bindsWithoutNarrowing(DartPattern pattern) => switch (pattern) {
    DeclaredVariablePattern(:final type) => type == null,
    WildcardPattern(:final type) => type == null,
    _ => false,
  };

  /// Reports a pattern that tests what the state is through its type
  /// annotation, which is the `is` test written as a pattern.
  ///
  /// Only where the pattern is matching something. The same syntax in a
  /// variable declaration is a destructuring, which tests nothing and drops
  /// nothing.
  static void _reportTypedPattern(
    DiagnosticReporter reporter,
    AstNode node,
    TypeAnnotation? annotation,
  ) {
    final type = annotation?.type;
    if (type is! InterfaceType) return;
    if (!_statePatterns.contains(type.element.name)) return;
    if (!_isRiverpodState(type)) return;
    if (node.thisOrAncestorOfType<GuardedPattern>() == null) return;
    reporter.atNode(annotation!, _code);
  }

  /// The property a pattern field reads, whether it was named or taken from the
  /// variable it binds.
  static String? _fieldName(PatternField field) {
    final explicit = field.name?.name?.lexeme;
    if (explicit != null) return explicit;
    final pattern = field.pattern;
    final bound = pattern is NullCheckPattern ? pattern.pattern : pattern;
    return bound is DeclaredVariablePattern ? bound.name.lexeme : null;
  }

  static bool _passesTrue(MethodInvocation node, String name) {
    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) continue;
      if (argument.name.label.name != name) continue;
      final value = argument.expression;
      return value is BooleanLiteral && value.value;
    }
    return false;
  }
}

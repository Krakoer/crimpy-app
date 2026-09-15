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
///   - an `AsyncData(...)` or `AsyncError(...)` pattern, which matches on the
///     state's type rather than on what it holds;
///   - `when(...)` or `maybeWhen(...)` without `skipLoadingOnReload: true` and
///     `skipError: true`, which default to false.
///
/// Read `value` instead, or match `AsyncValue(:final value?)`, or pass both
/// skip flags. Where the blanking is wanted, `// ignore` it and say why: a run
/// screen that must not show stale numbers is a real case.
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
        'Read `value`, or match `AsyncValue(:final value?)`, or pass '
        'skipLoadingOnReload: true and skipError: true.',
  );

  static const _asyncValueNames = {'AsyncValue', 'AsyncData', 'AsyncError',
    'AsyncLoading'};

  static bool _isAsyncValue(DartType? type) {
    if (type is! InterfaceType) return false;
    for (final t in [type, ...type.allSupertypes]) {
      if (_asyncValueNames.contains(t.element.name)) return true;
    }
    return false;
  }

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

    // `AsyncData(...)` / `AsyncError(...)` as a pattern, which is a test of the
    // state's type where what was meant was a test of what it holds.
    context.registry.addObjectPattern((node) {
      final name = node.type.name.lexeme;
      if (name != 'AsyncData' && name != 'AsyncError') return;
      if (!_isAsyncValue(node.type.type)) return;
      reporter.atNode(node.type, _code);
    });

    // `when(...)` and `maybeWhen(...)`, whose skip flags both default to false.
    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      if (name != 'when' && name != 'maybeWhen') return;
      if (!_isAsyncValue(node.realTarget?.staticType)) return;
      if (_passesTrue(node, 'skipLoadingOnReload') &&
          _passesTrue(node, 'skipError')) {
        return;
      }
      reporter.atNode(node.methodName, _code);
    });
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

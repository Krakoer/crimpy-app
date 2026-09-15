import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/keep_the_held_value.dart';

PluginBase createPlugin() => _CrimpyLints();

class _CrimpyLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const KeepTheHeldValue(),
  ];
}

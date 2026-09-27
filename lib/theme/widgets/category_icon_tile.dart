import 'package:flutter/material.dart';
import '../crimpy_theme.dart';

/// A category's icon in a square on a neutral ground. The category's colour is
/// carried by the icon alone: no tinted ground and no coloured border, so a
/// screen full of categories stays quiet. See Krakoer/crimpy#170.
class CategoryIconTile extends StatelessWidget {
  final IconData icon;
  final Color category;
  final double iconSize;

  /// A fixed side, for tiles that line up in a column. Without one the tile
  /// wraps the icon with a fixed padding.
  final double? size;

  const CategoryIconTile({
    required this.icon,
    required this.category,
    this.iconSize = 20,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: size == null ? null : Alignment.center,
    padding: size == null ? const EdgeInsets.all(CrimpyTheme.spaceSm) : null,
    decoration: BoxDecoration(
      color: CrimpyTheme.bgPrimary,
      border: Border.all(color: CrimpyTheme.outlineSubtle),
    ),
    child: Icon(icon, color: CrimpyTheme.markOn(category), size: iconSize),
  );
}

import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

class DashboardActionTile extends StatelessWidget {
  const DashboardActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          excludeFromSemantics: true,
          child: ExcludeSemantics(
            child: Ink(
              child: AppMiniCard.icon(icon: icon, label: label),
            ),
          ),
        ),
      ),
    );
  }
}

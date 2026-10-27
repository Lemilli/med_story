import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/l10n.dart';

/// Presentation only: the shell continues to own branch selection and history.
class ClearIndexNavigationBar extends StatelessWidget {
  const ClearIndexNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.navTimeline,
      context.l10n.navCapture,
      context.l10n.navSummary,
    ];
    const icons = [
      Icons.auto_stories_outlined,
      Icons.add_rounded,
      Icons.assignment_outlined,
    ];

    return Material(
      color: AppColors.clinicalWhite,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.clinicalLine)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < labels.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        button: true,
                        enabled: true,
                        selected: selectedIndex == index,
                        inMutuallyExclusiveGroup: true,
                        label:
                            '${labels[index]}\n${MaterialLocalizations.of(context).tabLabel(tabIndex: index + 1, tabCount: labels.length)}',
                        child: Tooltip(
                          message: labels[index],
                          excludeFromSemantics: true,
                          child: InkWell(
                            onTap: () => onDestinationSelected(index),
                            borderRadius: BorderRadius.circular(4),
                            child: ExcludeSemantics(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 64,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: index == 1 ? 32 : 28,
                                        decoration: BoxDecoration(
                                          color: index == 1
                                              ? AppColors.cobalt
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          icons[index],
                                          size: 22,
                                          color: index == 1
                                              ? AppColors.clinicalWhite
                                              : selectedIndex == index
                                              ? AppColors.cobalt
                                              : AppColors.secondaryInk,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        labels[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                          color: selectedIndex == index
                                              ? AppColors.cobalt
                                              : AppColors.secondaryInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

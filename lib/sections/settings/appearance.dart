import 'package:flutter/material.dart';
import '../../data/themes.dart';
import '../../data/colors.dart';
import '../../nav.dart';

final Map<EnscribeTheme, AppColors> themeColors = {
  EnscribeTheme.onyx: AppColorPalettes.onyx,
  EnscribeTheme.midnight: AppColorPalettes.midnight,
  EnscribeTheme.burgundy: AppColorPalettes.burgundy,
  EnscribeTheme.graphene: AppColorPalettes.graphene,
  EnscribeTheme.lumen: AppColorPalettes.lumen,
  EnscribeTheme.beige: AppColorPalettes.beige,
  EnscribeTheme.amethyst: AppColorPalettes.amethyst,
  EnscribeTheme.lavender: AppColorPalettes.lavender,
  EnscribeTheme.aqua: AppColorPalettes.aqua,
  EnscribeTheme.mint: AppColorPalettes.mint,
};

class AppearanceSection extends StatefulWidget {
  final EnscribeTheme selectedTheme;
  final ValueChanged<EnscribeTheme> onThemeChanged;
  final Color onSurface;
  final Color accent;
  final Color background;
  final Color textColor;
  final TextStyle titleStyle;
  final ThemeData theme;

  // NEW: current selected nav position + callback for changes
  final NavBarPosition selectedNavBarPosition;
  final ValueChanged<NavBarPosition> onNavBarPositionChanged;

  const AppearanceSection({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.onSurface,
    required this.accent,
    required this.background,
    required this.textColor,
    required this.titleStyle,
    required this.theme,
    required this.selectedNavBarPosition,
    required this.onNavBarPositionChanged,
  });

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection>
    with AutomaticKeepAliveClientMixin {
  bool _expanded = false;
  bool _navExpanded = false;

  @override
  bool get wantKeepAlive => false; // Reset when navigating away

  final List<String> _navLabels = ['Top', 'Bottom', 'Left', 'Right'];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Appearance',
                style: widget.titleStyle.copyWith(color: widget.accent),
              ),
            ),
            const SizedBox(height: 12),

            // Theme section
            Container(
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Theme header (top rounded corners)
                  InkWell(
                    onTap: () {
                      setState(() => _expanded = !_expanded);
                    },
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.theme.brightness == Brightness.dark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: 28.0,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Theme',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Choose your theme',
                                  style: TextStyle(
                                    color: widget.onSurface.withAlpha(153),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: widget.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Theme expanded grid
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 400;

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: isNarrow ? 2.4 : 3.2,
                            children: EnscribeTheme.values.map((theme) {
                              final info = themeDescriptions[theme]!;
                              final colors = themeColors[theme]!;
                              final isSelected = theme == widget.selectedTheme;

                              return GestureDetector(
                                onTap: () => widget.onThemeChanged(theme),
                                child: AnimatedContainer(
                                  height: 256,
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? widget.accent.withAlpha(26)
                                        : widget.background.withAlpha(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? widget.accent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: colors.accentColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              info.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: widget.textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              info.description,
                                              style: TextStyle(
                                                color: widget.onSurface
                                                    .withAlpha(153),
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Bar section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NavBar header (top rounded corners)
                  InkWell(
                    onTap: () {
                      setState(() => _navExpanded = !_navExpanded);
                    },
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_sidebar_rounded,
                            size: 28.0,
                            color: widget.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Navigation Bar',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Choose position',
                                  style: TextStyle(
                                    color: widget.onSurface.withAlpha(153),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _navExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: widget.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // NavBar expanded toggle buttons (bottom rounded corners)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ToggleButtons(
                        isSelected: [
                          widget.selectedNavBarPosition == NavBarPosition.top,
                          widget.selectedNavBarPosition ==
                              NavBarPosition.bottom,
                          widget.selectedNavBarPosition == NavBarPosition.left,
                          widget.selectedNavBarPosition == NavBarPosition.right,
                        ],
                        onPressed: (index) {
                          setState(() {
                            final newPos = NavBarPosition.values[index];
                            widget.onNavBarPositionChanged(newPos);
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        selectedBorderColor: widget.accent,
                        selectedColor: widget.accent,
                        fillColor: widget.accent.withAlpha(26),
                        color: widget.onSurface.withAlpha(153),
                        constraints: const BoxConstraints(
                          minWidth: 64,
                          minHeight: 36,
                        ),
                        children: _navLabels
                            .map((label) => Text(label))
                            .toList(),
                      ),
                    ),
                    crossFadeState: _navExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

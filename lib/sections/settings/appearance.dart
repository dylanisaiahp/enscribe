import 'package:flutter/material.dart';
import '../../data/themes.dart';
import '../../data/colors.dart';

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
  });

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection>
    with AutomaticKeepAliveClientMixin {
  bool _expanded = false;

  @override
  bool get wantKeepAlive => false; // Reset when navigating away

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

            // Combined container for header + expanded grid
            Container(
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with top rounded corners only
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

                  // Expanded section with bottom rounded corners & lerp background
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3.2,
                        children: EnscribeTheme.values.map((theme) {
                          final info = themeDescriptions[theme]!;
                          final colors = themeColors[theme]!;
                          final isSelected = theme == widget.selectedTheme;

                          return GestureDetector(
                            onTap: () => widget.onThemeChanged(theme),
                            child: AnimatedContainer(
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
                                            color: widget.onSurface.withAlpha(
                                              153,
                                            ),
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
          ],
        ),
      ),
    );
  }
}

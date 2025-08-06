// Card UI & helper widgets for HomePage
import 'package:flutter/material.dart';
import '../data/card.dart';

/// Builds the main card body text for a note card.
Widget buildCardText(BuildContext context,
    CardData card,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,) {
  final cardBgColor = card.backgroundColor ?? Theme
      .of(context)
      .colorScheme
      .surface;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        card.title.isNotEmpty ? card.title : 'Untitled',
        style: Theme
            .of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
          color: getOptimalTextColor(context, cardBgColor, Theme
              .of(context)
              .textTheme
              .titleLarge),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        (card.content?.isNotEmpty == true) ? card.content! : 'No content',
        style: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
          color: getOptimalTextColor(context, cardBgColor, Theme
              .of(context)
              .textTheme
              .bodyMedium),
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

/// Builds the metadata row (category & date) for a note card.
Widget buildCardMetadata(BuildContext context,
    CardData card,
    bool showCategory,
    bool showDateTime,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,
    String? formattedDate,) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (showCategory && (card.category?.isNotEmpty ?? false))
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: card.categoryColor ?? Theme
                .of(context)
                .colorScheme
                .primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            card.category!,
            style: Theme
                .of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              color: getOptimalTextColor(
                  context,
                  card.categoryColor ?? Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  Theme
                      .of(context)
                      .textTheme
                      .bodySmall
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      if (showDateTime && formattedDate != null)
        Text(
          formattedDate,
          style: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: Theme
                .of(context)
                .colorScheme
                .onSurface
                .withAlpha(153),
          ),
        ),
    ],
  );
}

/// Used for overlay text on images (always white for overlay contrast).
Widget buildCardTextOverlay(BuildContext context, CardData card) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        card.title.isNotEmpty ? card.title : 'Untitled',
        style: Theme
            .of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (card.content?.isNotEmpty == true) ...[
        const SizedBox(height: 4),
        Text(
          card.content!,
          style: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: Colors.white.withAlpha(204),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 8),
    ],
  );
}

/// Overlay metadata (category/date, for image overlay)
Widget buildOverlayMetadata(BuildContext context, CardData card,
    bool showCategory, bool showDateTime, String? formattedDate) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (showCategory && (card.category?.isNotEmpty ?? false))
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            card.category!,
            style: Theme
                .of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      if (showDateTime && formattedDate != null)
        Text(
          formattedDate,
          style: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: Colors.white.withAlpha(204),
          ),
        ),
    ],
  );
}

/// Selection indicator used for selected cards.
Widget buildSelectionIndicator(BuildContext context) {
  return Positioned(
    top: 12,
    right: 12,
    child: Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        size: 16,
      ),
    ),
  );
}

/// Wraps a card widget with proper gesture handling and semantics.
Widget buildCardWrapper({
  required BuildContext context,
  required CardData card,
  required bool isSelected,
  required VoidCallback onTap,
  required VoidCallback onLongPress,
  required Widget child,
}) {
  return Semantics(
    label: 'Note titled ${card.title.isNotEmpty
        ? card.title
        : 'Untitled'}${isSelected ? ', selected' : ''}',
    selected: isSelected,
    child: GestureDetector(
      key: ValueKey(card.id),
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    ),
  );
}

/// Builds a grid card for the home page card grid.
/// Requires caller to compose the card's main content and image section.
Widget buildGridCard(BuildContext context,
    CardData card,
    bool isSelected,
    bool showCategory,
    bool showDateTime,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,
    String? formattedDate,
    Widget imageSection,
    VoidCallback onTap,
    VoidCallback onLongPress,) {
  return buildCardWrapper(
    context: context,
    card: card,
    isSelected: isSelected,
    onTap: onTap,
    onLongPress: onLongPress,
    child: Stack(
      children: [
        Card(
          elevation: isSelected ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              width: 2,
            )
                : BorderSide.none,
          ),
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageSection,
          ),
        ),
        if (isSelected) buildSelectionIndicator(context),
      ],
    ),
  );
}

/// Builds a list card for the home page card list.
/// Requires caller to compose the card's main content and image section.
Widget buildListCard(BuildContext context,
    CardData card,
    bool isSelected,
    bool showCategory,
    bool showDateTime,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,
    String? formattedDate,
    Widget imageSection,
    VoidCallback onTap,
    VoidCallback onLongPress,) {
  return buildCardWrapper(
    context: context,
    card: card,
    isSelected: isSelected,
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Card(
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isSelected
                  ? BorderSide(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                width: 2,
              )
                  : BorderSide.none,
            ),
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageSection,
            ),
          ),
          if (isSelected) buildSelectionIndicator(context),
        ],
      ),
    ),
  );
}
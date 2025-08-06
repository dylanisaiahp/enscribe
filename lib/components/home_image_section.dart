import 'package:flutter/material.dart';
import '../data/card.dart';
import 'home_card_widgets.dart';

/// Builds the image+content (and overlays) for a grid card.
Widget gridCardImageSection(BuildContext context,
    CardData card,
    Widget Function({required String? imageUrl, required double width, required double height, BoxFit fit}) imageFallback,
    bool showCategory,
    bool showDateTime,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,
    String formattedDate,) {
  if (card.imageUrl != null && card.imageUrl!.isNotEmpty) {
    if (card.imageIsBackground == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          imageFallback(imageUrl: card.imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover),
          Container(
            color: card.backgroundColor ?? Theme
                .of(context)
                .colorScheme
                .secondary,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCardText(context, card, getOptimalTextColor),
                buildCardMetadata(context, card, showCategory, showDateTime,
                    getOptimalTextColor, formattedDate),
              ],
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        height: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: imageFallback(imageUrl: card.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(179),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCardTextOverlay(context, card),
                  buildOverlayMetadata(
                      context, card, showCategory, showDateTime, formattedDate),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  return Container(
    color: card.backgroundColor ?? Theme
        .of(context)
        .colorScheme
        .surface,
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCardText(context, card, getOptimalTextColor),
        buildCardMetadata(
            context, card, showCategory, showDateTime, getOptimalTextColor,
            formattedDate),
      ],
    ),
  );
}

/// Builds the image+content (and overlays) for a list card.
Widget listCardImageSection(BuildContext context,
    CardData card,
    Widget Function({required String? imageUrl, required double width, required double height, BoxFit fit}) imageFallback,
    bool showCategory,
    bool showDateTime,
    Color Function(BuildContext, Color, TextStyle?) getOptimalTextColor,
    String formattedDate,) {
  // Logic is the same as grid; could parametrize instead if needed.
  return gridCardImageSection(
      context,
      card,
      imageFallback,
      showCategory,
      showDateTime,
      getOptimalTextColor,
      formattedDate);
}

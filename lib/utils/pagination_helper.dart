import 'package:flutter/material.dart';

class PaginationHelper {
  static List<String> paginateText({
    required String text,
    required double fontSize,
    required double lineHeight,
    required TextStyle textStyle,
    required double maxWidth,
    required double maxHeight,
    EdgeInsets padding = const EdgeInsets.all(20.0),
  }) {
    final double availableWidth = maxWidth - padding.horizontal;
    final double availableHeight = maxHeight - padding.vertical;

    final List<String> pages = [];
    int start = 0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    while (start < text.length) {
      int low = start;
      int high = text.length;
      int best = start;

      // Binary search to find how much text fits
      while (low <= high) {
        int mid = (low + high) ~/ 2;
        String testText = text.substring(start, mid);
        
        textPainter.text = TextSpan(
          text: testText,
          style: textStyle.copyWith(fontSize: fontSize, height: lineHeight),
        );
        textPainter.layout(maxWidth: availableWidth);

        if (textPainter.height <= availableHeight) {
          best = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }

      // If we didn't fill at least one character, we must take at least one to prevent infinite loop
      if (best == start && start < text.length) {
        best = start + 1;
      }

      // Try to break at a space or newline for better readability
      if (best < text.length) {
        String fittingText = text.substring(start, best);
        int lastSpace = fittingText.lastIndexOf(RegExp(r'\s'));
        if (lastSpace != -1 && lastSpace > 0) {
          best = start + lastSpace + 1;
        }
      }

      pages.add(text.substring(start, best).trim());
      start = best;
    }

    return pages;
  }
}

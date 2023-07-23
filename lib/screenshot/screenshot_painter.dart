import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const double _imageWidth = 1624;
const double _imageHeight = 1024;

class ScreenshotPainter {
  static Size dmgSize() {
    return const Size(_imageWidth, _imageHeight);
  }

  static void paintImage({
    required ui.Image image,
    required Rect outputRect,
    required Canvas canvas,
    required BoxFit fit,
  }) {
    final paint = Paint();
    paint.isAntiAlias = true;
    // paint.filterQuality = FilterQuality.medium;

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final FittedSizes sizes = applyBoxFit(fit, imageSize, outputRect.size);

    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);

    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);

    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
  }

  static void paintScreenshot({
    required Canvas canvas,
    required ui.Image screenshot,
    required ui.Image wallpaper,
    required ui.Image computerImage,
    required bool useImac,
    HighlightBox? highlightBox,
  }) {
    final rect = Offset.zero & const Size(_imageWidth, _imageHeight);

    // ===============================================
    // wallpaper

    final Paint bgPaint = Paint()
      ..color = const ui.Color.fromARGB(255, 44, 44, 44)
      ..isAntiAlias = true;

    Rect contentRect;
    if (useImac) {
      contentRect = Rect.fromLTRB(
        rect.left + 179,
        rect.top + 38,
        rect.right - 182,
        rect.bottom - 316,
      );
    } else {
      contentRect = Rect.fromLTRB(
        rect.left + 211,
        rect.top + 109,
        rect.right - 212,
        rect.bottom - 163,
      );
    }

    canvas.drawRect(contentRect, bgPaint);

    paintImage(
      image: wallpaper,
      canvas: canvas,
      fit: BoxFit.cover,
      outputRect: contentRect,
    );

    // ===============================================
    // screenshot

    paintImage(
      image: screenshot,
      canvas: canvas,
      fit: BoxFit.scaleDown,
      outputRect: contentRect,
    );

    // ===============================================
    // draw imac

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: _imageWidth - 40,
      height: _imageHeight,
    );

    paintImage(
      image: computerImage,
      canvas: canvas,
      fit: BoxFit.scaleDown,
      outputRect: imageRect,
    );

    if (highlightBox != null) {
      final Rect highlightRect = Rect.fromLTWH(
        contentRect.left + (contentRect.width * highlightBox.x),
        contentRect.top + (contentRect.height * highlightBox.y),
        contentRect.width * highlightBox.width,
        contentRect.height * highlightBox.height,
      );

      final Paint highlightPaint = Paint()
        ..color = const ui.Color.fromARGB(255, 255, 0, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..isAntiAlias = true;

      canvas.drawRect(highlightRect, highlightPaint);
    }
  }
}

// =============================================================

class HighlightBox {
  HighlightBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  // all values 0-1, relative to containing box
  double x;
  double y;
  double width;
  double height;
}

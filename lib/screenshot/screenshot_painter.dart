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
    required ui.Image image,
  }) {
    final rect = Offset.zero & const Size(_imageWidth, _imageHeight);

    // rect = rect.inflate(50);

    // ===============================================
    // background

    final Paint bgPaint = Paint()
      ..color = const ui.Color.fromARGB(255, 9, 57, 92)
      ..isAntiAlias = true;

    final Rect contentRect = Rect.fromLTRB(
      rect.left + 212,
      rect.top + 110,
      rect.right - 214,
      rect.bottom - 164,
    );

    canvas.drawRect(contentRect, bgPaint);

    // ===============================================
    // draw imac

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: _imageWidth - 40,
      height: _imageHeight,
    );

    paintImage(
      image: image,
      canvas: canvas,
      fit: BoxFit.scaleDown,
      outputRect: imageRect,
    );
  }
}

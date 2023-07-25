import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double _imageWidth = 1624;
const double _imageHeight = 1024;

class ScreenshotPainter {
  static Size dmgSize() {
    return const Size(_imageWidth, _imageHeight);
  }

  static void drawIcons({
    required Canvas canvas,
    required Rect contentRect,
    required Color color,
    required double fontSize,
  }) {
    drawIcon(
      canvas: canvas,
      color: color,
      fontSize: fontSize,
      icon: FontAwesomeIcons.apple,
      x: (contentRect.left + contentRect.width * 0.53) - (fontSize / 2),
      y: (contentRect.top + contentRect.height * 0.25) - (fontSize / 2),
    );

    drawIcon(
      canvas: canvas,
      color: color,
      fontSize: fontSize,
      icon: FontAwesomeIcons.windows,
      x: (contentRect.left + contentRect.width * 0.25) - (fontSize / 2),
      y: (contentRect.top + contentRect.height * 0.7) - (fontSize / 2),
    );

    drawIcon(
      canvas: canvas,
      color: color,
      fontSize: fontSize,
      icon: FontAwesomeIcons.linux,
      x: (contentRect.left + contentRect.width * 0.75) - (fontSize / 2),
      y: (contentRect.top + contentRect.height * 0.7) - (fontSize / 2),
    );
  }

  static void drawIcon({
    required Canvas canvas,
    required Color color,
    required double x,
    required double y,
    required IconData icon,
    required double fontSize,
  }) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: Colors.black45,
        fontSize: fontSize,
        fontFamily: icon.fontFamily,
        package:
            icon.fontPackage, // This line is mandatory for external icon packs
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 6, y + 6));

    textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: icon.fontFamily,
        package:
            icon.fontPackage, // This line is mandatory for external icon packs
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
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
    required ui.Image? screenshot2,
    required ui.Image? wallpaper,
    required ui.Color wallpaperColor,
    required ui.Image computerImage,
    required bool useImac,
    required HighlightBox highlightBox,
    required Offset screenshot2Position,
    required bool platformLogoMode,
  }) {
    final rect = Offset.zero & const Size(_imageWidth, _imageHeight);

    // ===============================================
    // wallpaper

    final Paint bgPaint = Paint()
      ..color = wallpaperColor
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

    if (wallpaper != null) {
      paintImage(
        image: wallpaper,
        canvas: canvas,
        fit: BoxFit.cover,
        outputRect: contentRect,
      );
    }

    // ===============================================
    // screenshot

    if (platformLogoMode) {
      drawIcons(
        canvas: canvas,
        contentRect: contentRect,
        color: Colors.white,
        fontSize: 340,
      );
    } else {
      paintImage(
        image: screenshot,
        canvas: canvas,
        fit: BoxFit.scaleDown,
        outputRect: contentRect,
      );

      if (screenshot2 != null) {
        canvas.save();
        canvas.clipRect(contentRect);
        canvas.translate(
          contentRect.width * screenshot2Position.dx,
          contentRect.height * screenshot2Position.dy,
        );

        paintImage(
          image: screenshot2,
          canvas: canvas,
          fit: BoxFit.scaleDown,
          outputRect: contentRect,
        );
        canvas.restore();
      }
    }

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

    if (!highlightBox.isZero()) {
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

      canvas.drawRRect(
        RRect.fromRectAndRadius(highlightRect, const Radius.circular(16)),
        highlightPaint,
      );
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

  HighlightBox.zero({
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
  });

  // all values 0-1, relative to containing box
  double x;
  double y;
  double width;
  double height;

  bool isZero() {
    return x == 0 && y == 0 && width == 0 && height == 0;
  }
}

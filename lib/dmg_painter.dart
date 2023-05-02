import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/utils/theme_prefs.dart';

class DmgPainter {
  static Size dmgSize({
    required bool twoX,
  }) {
    const dmgSize = Size(611, 400);

    if (twoX) {
      return dmgSize * 2;
    }

    return dmgSize;
  }

  static void paintDmg({
    required Canvas canvas,
    required ui.Image image,
    required bool twoX,
  }) {
    final rect = Offset.zero & dmgSize(twoX: true);

    if (!twoX) {
      canvas.scale(0.5);
    }
    // ===============================================
    // background

    final Paint bgPaint = Paint()
      ..color = Colors.cyan
      ..isAntiAlias = true;

    canvas.drawRect(rect, bgPaint);

    // ===============================================
    // draw arrow

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: image.width.toDouble(),
      height: image.height.toDouble(),
    );

    final Paint arrowPaint = Paint();
    arrowPaint.isAntiAlias = true;

    canvas.drawImage(image, imageRect.topLeft, arrowPaint);

    // ===============================================
    // draw Text

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Path Finder',
        style: styleWithGoogleFont(
          ThemePrefs().font.value,
          const TextStyle(fontSize: 64),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.size.width);

    textPainter.paint(canvas, const Offset(22, 22));
  }
}

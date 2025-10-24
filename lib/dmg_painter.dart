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

    final bgPaint = Paint()
      ..color = const ui.Color.fromARGB(255, 9, 57, 92)
      ..isAntiAlias = true;

    canvas.drawRect(rect, bgPaint);

    // ===============================================
    // background gradient

    final centerOvalPaint2 = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0),
        ],
        radius: 1,
      ).createShader(rect);

    canvas.drawRect(rect, centerOvalPaint2);

    // ===============================================
    // draw arrow

    final imageRect = Rect.fromCenter(
      center: rect.center,
      width: image.width.toDouble(),
      height: image.height.toDouble(),
    );

    final arrowPaint = Paint();
    arrowPaint.isAntiAlias = true;

    canvas.drawImage(image, imageRect.topLeft, arrowPaint);

    // ===============================================
    // draw header text

    const horizOffset = 72.0;
    const vertOffset = 52.0;
    final footerVertOffset = rect.size.height - vertOffset - 60;
    const footerFontSize = 34.0;
    const headerFontSize = 96.0;
    const appName = 'DECKR';

    final textPainter = TextPainter(
      text: TextSpan(
        text: appName,
        style: FontUtils.styleWithGoogleFont(
          ThemePrefs().font.value,
          const TextStyle(fontSize: headerFontSize),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.size.width);

    textPainter.paint(canvas, const Offset(horizOffset, vertOffset));

    // ===============================================
    // draw footer text

    final footerPainter = TextPainter(
      text: TextSpan(
        text: 'Drag $appName to the Applications folder to install',
        style: FontUtils.styleWithGoogleFont(
          'Roboto',
          const TextStyle(fontSize: footerFontSize),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.size.width);

    footerPainter.paint(canvas, Offset(horizOffset, footerVertOffset));
  }
}

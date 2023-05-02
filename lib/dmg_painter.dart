import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// =========================================================

class DmgPainter {
  // =======================================================
  // static methods

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

    final paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 32));
    paragraphBuilder.addText('Path Finder');

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: dmgSize(twoX: twoX).width));

    canvas.drawParagraph(paragraph, const Offset(12, 12));
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// =========================================================

class DmgPainter extends CustomPainter {
  const DmgPainter({
    required this.image,
  });

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    paintDmg(
      canvas: canvas,
      size: size,
      image: image,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  // =======================================================
  // static methods

  // static const dmgSize = Size(611, 400);
  static const dmgSize = Size(1222, 800);

  static void paintDmg({
    required Canvas canvas,
    required Size size,
    required ui.Image image,
  }) {
    final rect = Offset.zero & size;

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
  }
}

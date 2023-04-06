import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';

// =========================================================

class IconPainter extends CustomPainter {
  const IconPainter({
    required this.image,
  });

  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    paintIcon(canvas, size, image);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  // =======================================================
  // static methods

  static const double baseIconSize = 1024;
  static const double svgIconSize = 600;

  static void paintIcon(
    Canvas canvas,
    Size size,
    ui.Image? image,
  ) {
    const realSize = Size(baseIconSize, baseIconSize);
    final scale = size.width / realSize.width;

    canvas.scale(scale);

    final rect = Offset.zero & realSize;

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: svgIconSize,
      height: svgIconSize,
    );

    // ===============================================

    final mainRect = rect.deflate(18);
    final innerRect = rect.deflate(90);

    const startColor = Color.fromRGBO(55, 55, 55, 1);
    const endColor = Color.fromRGBO(105, 155, 222, 1);

    final outerRRect = RRect.fromRectAndRadius(
      mainRect,
      const Radius.circular(165),
    );

    final backPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = startColor.mix(endColor, 0.4)!;

    canvas.drawShadow(
      Path()..addRRect(outerRRect),
      Colors.black,
      10,
      true,
    );

    canvas.drawRRect(outerRRect, backPaint);

    // =================================================

    const color = Colors.cyan;

    final rrectPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color;

    rrectPaint.shader = const RadialGradient(
      colors: [Colors.white, color],
    ).createShader(mainRect);

    canvas.drawOval(innerRect, rrectPaint);

    final framePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.grey[800]!;

    canvas.drawOval(innerRect, framePaint);

    // ===============================================

    final Paint blendPaint = Paint();
    blendPaint.blendMode = ui.BlendMode.dstIn;
    blendPaint.isAntiAlias = true;

    final Paint gradientPaint = Paint();
    gradientPaint.shader = const LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    gradientPaint.isAntiAlias = true;

    if (image != null) {
      // this gets rid of frame? not sure what is happening
      // canvas.saveLayer(rect, Paint());
      canvas.saveLayer(imageRect.deflate(6), Paint());

      canvas.drawOval(imageRect, gradientPaint);
      canvas.drawImage(image, imageRect.topLeft, blendPaint);

      canvas.restore();
    }
  }
}

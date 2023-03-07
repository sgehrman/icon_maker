import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';

// =========================================================

class IconPainter extends CustomPainter {
  const IconPainter({
    required this.color,
    required this.image,
  });

  final Color color;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    paintIcon(canvas, size, color, image);
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
    Color color,
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

    const startColor = Color.fromRGBO(55, 55, 55, 1);
    const endColor = Color.fromRGBO(105, 155, 222, 1);

    final Paint gradientPaint = Paint();
    gradientPaint.shader = const LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    gradientPaint.isAntiAlias = true;

    final Paint blendPaint = Paint();
    blendPaint.blendMode = ui.BlendMode.dstIn;
    blendPaint.isAntiAlias = true;

    // ------------------------------------------------
    // draw oval
    final ovalRect = rect.deflate(12);

    canvas.drawShadow(
      Path()..addOval(ovalRect),
      Colors.black,
      12,
      true,
    );

    final ovalPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color;

    ovalPaint.shader = RadialGradient(
      colors: [Colors.white, color],
    ).createShader(ovalRect);
    canvas.drawOval(ovalRect, ovalPaint);

    final ovalLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..color = startColor.mix(endColor, 0.4)!;

    canvas.drawPath(Path()..addOval(ovalRect.deflate(30)), ovalLinePaint);

    // ------------------------------------------------

    if (image != null) {
      // this gets rid of frame? not sure what is happening
      // canvas.saveLayer(rect, Paint());
      canvas.saveLayer(imageRect.deflate(6), Paint());

      canvas.drawRect(imageRect, gradientPaint);
      canvas.drawImage(image, imageRect.topLeft, blendPaint);

      canvas.restore();
    }
  }
}

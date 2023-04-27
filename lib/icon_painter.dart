import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';

// =========================================================

class IconPainter extends CustomPainter {
  const IconPainter({
    required this.image,
    this.insetImage = true,
  });

  final ui.Image? image;
  final bool insetImage;

  static bool safariMode = false;

  @override
  void paint(Canvas canvas, Size size) {
    paintIcon(
      canvas: canvas,
      size: size,
      image: image,
      insetImage: insetImage,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  // =======================================================
  // static methods

  static const double baseIconSize = 1024;
  static double svgIconSize = IconPainter.safariMode ? 500 : 600;

  static void paintIcon({
    required Canvas canvas,
    required Size size,
    required ui.Image? image,
    required bool insetImage,
  }) {
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

    // insetImage set to false for small images, don't waste space
    final mainRect = rect.deflate(insetImage ? 20 : 0);
    final ovalRect = mainRect.deflate(80);

    const startColor = Color.fromRGBO(45, 45, 45, 1);
    const endColor = Color.fromRGBO(59, 112, 158, 1);

    final outerRRect = RRect.fromRectAndRadius(
      mainRect,
      const Radius.circular(250),
    );

    final backStartColor = startColor.mix(endColor, 0.7)!;
    final backEndColor = startColor.mix(endColor, 0.2)!;

    final backPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [backStartColor, backEndColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawShadow(
      Path()..addRRect(outerRRect),
      Colors.black,
      10,
      true,
    );

    canvas.drawRRect(outerRRect, backPaint);

    // =================================================
    // stroke around background

    final borderStartColor = startColor.mix(endColor, 0.4)!;
    final borderEndColor = startColor.mix(endColor, 0.1)!;

    final borderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [borderStartColor, borderEndColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawRRect(outerRRect, borderPaint);

    // =================================================
    // cemter oval

    const centerOvalColor = Colors.cyan;
    const centerOvalEndColor = ui.Color.fromARGB(255, 0, 125, 142);

    final centerOvalPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [centerOvalColor, centerOvalEndColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(mainRect);

    canvas.drawOval(ovalRect, centerOvalPaint);

    final centerOvalPaint2 = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0)],
        radius: 0.4,
      ).createShader(mainRect);

    canvas.drawOval(ovalRect, centerOvalPaint2);

    // ===============================================
    // frame around oval

    final ovalBorderStartColor = Colors.grey[600]!;
    final ovalBorderEndColor = Colors.grey[900]!;

    final ovalBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [ovalBorderStartColor, ovalBorderEndColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawOval(ovalRect, ovalBorderPaint);

    // ===============================================
    // draw icon in center

    final Paint blendPaint = Paint();
    blendPaint.blendMode = ui.BlendMode.dstIn;
    blendPaint.isAntiAlias = true;

    final Paint gradientPaint = Paint();
    gradientPaint.shader = LinearGradient(
      colors: [backStartColor, backEndColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    gradientPaint.isAntiAlias = true;

    if (image != null) {
      // this gets rid of frame? not sure what is happening
      // canvas.saveLayer(rect, Paint());
      canvas.saveLayer(imageRect.deflate(6), Paint());

      if (IconPainter.safariMode) {
        // canvas.translate(imageRect.center.dx, imageRect.center.dy);
        // canvas.rotate(math.pi * 0.75);
        // canvas.translate(-imageRect.center.dx, -imageRect.center.dy);
        canvas.translate(20, 0);
      }

      canvas.drawOval(imageRect, gradientPaint);
      canvas.drawImage(image, imageRect.topLeft, blendPaint);

      canvas.restore();
    }
  }
}

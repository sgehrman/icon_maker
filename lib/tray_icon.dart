import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class TrayIcon {
  static const faviconPath = './favicon.png';
  static const faviconIcoPath = './favicon.ico';

  static Future<Uint8List> _generateFavicon(double size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final rect = Offset.zero & Size(size, size);
    final ovalRect = rect.deflate(1);

    const color = Colors.cyan;
    final startColor = Colors.white.mix(Colors.cyan, 0.5) ?? Colors.white;

    final ovalPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color;

    ovalPaint.shader = RadialGradient(
      radius: 1,
      colors: [startColor, color],
    ).createShader(ovalRect);
    canvas.drawOval(ovalRect, ovalPaint);

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(size.toInt(), size.toInt());

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static Future<void> saveFavIcon() async {
    var imageData = await _generateFavicon(32);

    File file = File(faviconPath);
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );

    // write out ico
    final img.Image image = img.decodeImage(imageData)!;

    imageData = img.encodeIco(image);

    file = File(faviconIcoPath);
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum TrayIconMode {
  cyan,
  white,
  black,
  red,
  green,
  blue,
  yellow,
  orange,
}

enum TrayIconSize {
  small,
  medium,
  large,
}

class TrayIcon {
  TrayIcon(this.size, this.colorMode);

  final TrayIconMode colorMode;
  final TrayIconSize size;

  Color get _fillColor {
    switch (colorMode) {
      case TrayIconMode.cyan:
        return Colors.cyan;
      case TrayIconMode.white:
        return Colors.white;
      case TrayIconMode.black:
        return Colors.black;
      case TrayIconMode.red:
        return Colors.red;
      case TrayIconMode.orange:
        return Colors.deepOrange;
      case TrayIconMode.green:
        return Colors.green;
      case TrayIconMode.blue:
        return Colors.blue;
      case TrayIconMode.yellow:
        return Colors.yellow;
    }
  }

  Color get _startColor {
    double whiteMix = 0.5;

    switch (colorMode) {
      case TrayIconMode.cyan:
      case TrayIconMode.white:
      case TrayIconMode.red:
      case TrayIconMode.orange:
      case TrayIconMode.green:
      case TrayIconMode.blue:
      case TrayIconMode.yellow:
        break;
      case TrayIconMode.black:
        // too much white on black is ugly
        whiteMix = 0.9;
        break;
    }

    return Colors.white.mix(_fillColor, whiteMix) ?? Colors.white;
  }

  double get _iconInset {
    switch (size) {
      case TrayIconSize.small:
        return 6;
      case TrayIconSize.medium:
        return 3;
      case TrayIconSize.large:
        return 1;
    }
  }

  String get _nameTags {
    String result = '';

    switch (colorMode) {
      case TrayIconMode.cyan:
        result += '-cyan';
        break;
      case TrayIconMode.white:
        result += '-white';
        break;
      case TrayIconMode.black:
        result += '-black';
        break;
      case TrayIconMode.red:
        result += '-red';
        break;
      case TrayIconMode.orange:
        result += '-orange';
        break;
      case TrayIconMode.green:
        result += '-green';
        break;
      case TrayIconMode.blue:
        result += '-blue';
        break;
      case TrayIconMode.yellow:
        result += '-yellow';
        break;
    }

    switch (size) {
      case TrayIconSize.small:
        result += '-sm';
        break;
      case TrayIconSize.medium:
        result += '-md';
        break;
      case TrayIconSize.large:
        result += '-lg';
        break;
    }

    return result;
  }

  String get faviconPath {
    return './icons/png/favicon$_nameTags.png';
  }

  String get faviconIcoPath {
    return './icons/ico/favicon$_nameTags.ico';
  }

  Future<Uint8List> _generateFavicon(double size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final rect = Offset.zero & Size(size, size);
    final ovalRect = rect.deflate(_iconInset);

    final ovalPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = _fillColor;

    ovalPaint.shader = RadialGradient(
      radius: 1,
      colors: [_startColor, _fillColor],
    ).createShader(ovalRect);
    canvas.drawOval(ovalRect, ovalPaint);

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(size.toInt(), size.toInt());

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveFavIcon() async {
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

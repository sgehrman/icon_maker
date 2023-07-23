import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/services.dart';

class ScreenshotAssets {
  late final List<ui.Image> _screenshots = [];
  late ui.Image _iMacImage;
  late ui.Image _macBookImage;
  late ui.Image _wallpaper;
  bool useImac = false;
  int screenshotIndex = 0;

  final void Function() _loaded;

  ScreenshotAssets(this._loaded) {
    _setup();
  }

  int get screenshotCount {
    return _screenshots.length;
  }

  ui.Image get screenshot {
    return _screenshots[screenshotIndex];
  }

  ui.Image get computerImage {
    if (useImac) {
      return _iMacImage;
    }

    return _macBookImage;
  }

  ui.Image get wallpaper {
    return _wallpaper;
  }

  Future<void> _setup() async {
    ByteData byteData = await rootBundle.load('assets/imac.png');

    _iMacImage =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    // ----------------------------------------------

    byteData = await rootBundle.load('assets/macbook.png');
    _macBookImage =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    // ----------------------------------------------

    byteData = await rootBundle.load('assets/catalina.jpg');
    // byteData = await rootBundle.load('assets/sonoma.jpg');

    _wallpaper =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    // ----------------------------------------------

    for (int i = 0; i < 2; i++) {
      byteData = await rootBundle.load('assets/ss-$i.png');

      _screenshots.add(
        await ImageProcessor.bytesToImage(
          byteData.buffer.asUint8List(),
        ),
      );
    }

    _loaded();
  }
}

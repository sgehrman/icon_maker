import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/services.dart';

class ScreenshotAssets {
  late final List<ui.Image> _screenshots = [];
  late final List<ui.Image> _wallpapers = [];
  late ui.Image _iMacImage;
  late ui.Image _macBookImage;
  bool useImac = false;
  int screenshotIndex = 0;
  int wallpaperIndex = 0;

  final int numScreenshots = 2;

  final void Function() _loaded;

  ScreenshotAssets(this._loaded) {
    _setup();
  }

  int get screenshotCount {
    return _screenshots.length;
  }

  int get wallpaperCount {
    return _wallpapers.length;
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
    return _wallpapers[wallpaperIndex];
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

    final wallpaperFilenames = [
      'catalina',
      'sonoma',
      'colored-clouds',
      'galaxy',
      'purple-wave',
      'wave',
    ];

    for (final name in wallpaperFilenames) {
      byteData = await rootBundle.load('assets/wallpaper/$name.jpg');

      _wallpapers.add(
        await ImageProcessor.bytesToImage(
          byteData.buffer.asUint8List(),
        ),
      );
    }

    // ----------------------------------------------
    // 2517 × 1616

    for (int i = 0; i < numScreenshots; i++) {
      byteData = await rootBundle.load('assets/screenshots/ss-$i.png');

      _screenshots.add(
        await ImageProcessor.bytesToImage(
          byteData.buffer.asUint8List(),
        ),
      );
    }

    _loaded();
  }
}

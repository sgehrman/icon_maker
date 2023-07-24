import 'dart:async';
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
  int screenshot2Index = 0;
  int wallpaperIndex = 0;
  final Completer<bool> _completer = Completer<bool>();

  final int numScreenshots = 4;

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

  Future<ui.Image> get screenshot async {
    await _completer.future;

    return _screenshots[screenshotIndex];
  }

  Future<ui.Image> get screenshot2 async {
    await _completer.future;

    return _screenshots[screenshot2Index];
  }

  Future<ui.Image> get computerImage async {
    await _completer.future;

    if (useImac) {
      return _iMacImage;
    }

    return _macBookImage;
  }

  Future<ui.Image> get wallpaper async {
    await _completer.future;

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

    _completer.complete(true);
    _loaded();
  }
}

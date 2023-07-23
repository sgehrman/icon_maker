import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icon_maker/screenshot/screenshot_assets.dart';
import 'package:icon_maker/screenshot/screenshot_painter.dart';

class ScreenshotScreen extends StatefulWidget {
  @override
  State<ScreenshotScreen> createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  Uint8List? _savedImage;
  ScreenshotAssets assets = ScreenshotAssets(() => print('loaded'));

  Future<void> _saveIcon() async {
    final int count = assets.screenshotCount;

    for (int i = 0; i < count; i++) {
      assets.screenshotIndex = i;

      assets.useImac = false;
      await saveImage(i);
      assets.useImac = true;
      await saveImage(i + 100);
    }

    _savedImage = await File(
      iconPathForSize(0),
    ).readAsBytes();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _saveIcon,
              child: const Text('Save Screenshot'),
            ),
            const SizedBox(height: 20),
            if (_savedImage != null) Image.memory(_savedImage!),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateIconData() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    ScreenshotPainter.paintScreenshot(
      canvas: canvas,
      screenshot: assets.screenshot,
      wallpaper: assets.wallpaper,
      computerImage: assets.computerImage,
      useImac: assets.useImac,
    );

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(
      ScreenshotPainter.dmgSize().width.toInt(),
      ScreenshotPainter.dmgSize().height.toInt(),
    );

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveImage(int index) async {
    final imageData = await _generateIconData();

    final File file = File(iconPathForSize(index));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );
  }

  String iconPathForSize(int index) {
    const iconBasePath = './icons/screenshots/';

    return '$iconBasePath/screenshot$index.png';
  }
}

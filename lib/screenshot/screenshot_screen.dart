import 'dart:io';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icon_maker/screenshot/screenshot_painter.dart';

class ScreenshotScreen extends StatefulWidget {
  @override
  State<ScreenshotScreen> createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  Uint8List? _savedImage;
  late ui.Image _screenshot;
  late ui.Image _computerImage;
  late ui.Image _wallpaper;
  bool useImac = false;

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    ByteData byteData;

    if (useImac) {
      byteData = await rootBundle.load('assets/imac.png');
    } else {
      byteData = await rootBundle.load('assets/macbook.png');
    }

    _computerImage =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    // ----------------------------------------------

    byteData = await rootBundle.load('assets/catalina.jpg');
    // byteData = await rootBundle.load('assets/sonoma.jpg');

    _wallpaper =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    // ----------------------------------------------

    byteData = await rootBundle.load('assets/ss-one.png');

    _screenshot =
        await ImageProcessor.bytesToImage(byteData.buffer.asUint8List());

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveIcon() async {
    await saveImage();

    _savedImage = await File(
      iconPathForSize(),
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
      screenshot: _screenshot,
      wallpaper: _wallpaper,
      computerImage: _computerImage,
      useImac: useImac,
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

  Future<void> saveImage() async {
    final imageData = await _generateIconData();

    final File file = File(iconPathForSize());
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );
  }

  String iconPathForSize() {
    const iconBasePath = './icons/screenshots/';

    return '$iconBasePath/screenshot.png';
  }
}

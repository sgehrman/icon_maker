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
  late ScreenshotAssets assets;
  final HighlightBox _highlightBox =
      HighlightBox(x: 0.2, y: 0.2, width: 0.2, height: 0.2);

  @override
  void initState() {
    super.initState();

    assets = ScreenshotAssets(
      () => setState(() {}),
    );
  }

  Future<void> _updateIcon() async {
    await saveImage(assets.screenshotIndex, write: false);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveIcon() async {
    await saveImage(assets.screenshotIndex);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveAllIcons() async {
    final int count = assets.screenshotCount;

    for (int i = 0; i < count; i++) {
      assets.screenshotIndex = i;

      assets.useImac = true;
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
              onPressed: _saveAllIcons,
              child: const Text('Save Screenshot'),
            ),
            Slider(
              value: _highlightBox.x,
              onChangeEnd: (value) {
                _updateIcon();
              },
              onChanged: (value) {
                _highlightBox.x = value;
                setState(() {});
              },
            ),
            Slider(
              value: _highlightBox.y,
              onChangeEnd: (value) {
                _updateIcon();
              },
              onChanged: (value) {
                _highlightBox.y = value;
                setState(() {});
              },
            ),
            Slider(
              value: _highlightBox.width,
              onChangeEnd: (value) {
                _updateIcon();
              },
              onChanged: (value) {
                _highlightBox.width = value;
                setState(() {});
              },
            ),
            Slider(
              value: _highlightBox.height,
              onChangeEnd: (value) {
                _updateIcon();
              },
              onChanged: (value) {
                _highlightBox.height = value;
                setState(() {});
              },
            ),
            CheckboxListTile(
              value: assets.useImac,
              onChanged: (value) {
                assets.useImac = value ?? false;
                _updateIcon();
              },
              title: const Text('Use iMac frame'),
            ),
            PopupMenuButton<int>(
              itemBuilder: (context) {
                final result = <PopupMenuItem<int>>[];

                for (int i = 0; i < assets.screenshotCount; i++) {
                  result.add(
                    PopupMenuItem<int>(
                      value: i,
                      child: Text('num: $i'),
                    ),
                  );
                }

                return result;
              },
              onSelected: (value) {
                assets.screenshotIndex = value;

                _updateIcon();
              },
              child: Text(
                'Screenshot ${assets.screenshotIndex}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
      highlightBox: _highlightBox,
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

  Future<void> saveImage(int index, {bool write = true}) async {
    _savedImage = await _generateIconData();

    if (write) {
      final File file = File(iconPathForSize(index));
      file.createSync(recursive: true);

      await file.writeAsBytes(
        _savedImage!,
      );
    }
  }

  String iconPathForSize(int index) {
    const iconBasePath = './icons/screenshots/';

    return '$iconBasePath/screenshot$index.png';
  }
}

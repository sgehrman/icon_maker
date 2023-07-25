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
      HighlightBox(x: 0, y: 0, width: 0.2, height: 0.2);
  bool showHightlightBox = false;
  bool useWallpaper = true;
  bool showSecondScreenshot = false;
  Offset _screenshot2Position = const Offset(0.3, 0.1);

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

  Widget _screenshotPopup() {
    return PopupMenuButton<int>(
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
    );
  }

  Widget _screenshot2Popup() {
    return PopupMenuButton<int>(
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
        assets.screenshot2Index = value;

        _updateIcon();
      },
      child: Text(
        'Screenshot #2 ${assets.screenshot2Index}',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _wallpaperPopup() {
    return PopupMenuButton<int>(
      itemBuilder: (context) {
        final result = <PopupMenuItem<int>>[];

        for (int i = 0; i < assets.wallpaperCount; i++) {
          result.add(
            PopupMenuItem<int>(
              value: i,
              child: Text('wallpaper: $i'),
            ),
          );
        }

        return result;
      },
      onSelected: (value) {
        assets.wallpaperIndex = value;
        _updateIcon();
      },
      child: Text(
        'Wallpaper ${assets.wallpaperIndex}',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
              child: const Text('Save All'),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: assets.useImac,
              onChanged: (value) {
                assets.useImac = value ?? false;
                _updateIcon();
              },
              title: const Text('Use iMac frame'),
            ),
            _screenshotPopup(),
            CheckboxListTile(
              value: showHightlightBox,
              onChanged: (value) {
                showHightlightBox = value ?? false;
                _updateIcon();
              },
              title: const Text('Use Highlight Box'),
            ),
            Row(
              children: [
                Flexible(
                  child: Slider(
                    value: _highlightBox.x,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _highlightBox.x = value;
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  child: Slider(
                    value: _highlightBox.y,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _highlightBox.y = value;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Slider(
                    value: _highlightBox.width,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _highlightBox.width = value;
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  child: Slider(
                    value: _highlightBox.height,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _highlightBox.height = value;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              value: useWallpaper,
              onChanged: (value) {
                useWallpaper = value ?? false;
                _updateIcon();
              },
              title: const Text('Use Wallpaper'),
            ),
            _wallpaperPopup(),
            CheckboxListTile(
              value: showSecondScreenshot,
              onChanged: (value) {
                showSecondScreenshot = value ?? false;
                _updateIcon();
              },
              title: const Text('Show Second Screenshot'),
            ),
            _screenshot2Popup(),
            Row(
              children: [
                Flexible(
                  child: Slider(
                    value: _screenshot2Position.dx,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _screenshot2Position =
                          Offset(value, _screenshot2Position.dy);
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  child: Slider(
                    value: _screenshot2Position.dy,
                    onChangeEnd: (value) {
                      _updateIcon();
                    },
                    onChanged: (value) {
                      _screenshot2Position =
                          Offset(_screenshot2Position.dx, value);
                      setState(() {});
                    },
                  ),
                ),
              ],
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
      screenshot: await assets.screenshot,
      screenshot2: showSecondScreenshot ? await assets.screenshot2 : null,
      wallpaper: useWallpaper ? await assets.wallpaper : null,
      wallpaperColor: const ui.Color.fromARGB(255, 44, 44, 44),
      // wallpaperColor: const ui.Color.fromARGB(255, 46, 86, 186),
      // wallpaperColor: const ui.Color.fromARGB(255, 58, 74, 119),

      computerImage: await assets.computerImage,
      useImac: assets.useImac,
      highlightBox: showHightlightBox ? _highlightBox : HighlightBox.zero(),
      screenshot2Position: _screenshot2Position,
      platformLogoMode: false,
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

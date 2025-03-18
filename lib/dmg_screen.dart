import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/dmg_painter.dart';
import 'package:icon_maker/utils/google_font_dialog.dart';
import 'package:icon_maker/utils/theme_prefs.dart';

class DmgScreen extends StatefulWidget {
  @override
  State<DmgScreen> createState() => _DmgScreenState();
}

class _DmgScreenState extends State<DmgScreen> {
  Uint8List? _savedImage2x;
  Uint8List? _savedImage;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    ThemePrefs().font.addListener(_listener);

    _setup();
  }

  @override
  void dispose() {
    ThemePrefs().font.removeListener(_listener);

    super.dispose();
  }

  void _listener() {
    _saveIcon();
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: FontAwesomeSvgs.solidArrowRight,
      size: 128,
      color: Colors.white70,
    );

    _image = await ImageProcessor.bytesToImage(iconData.bytes);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveIcon() async {
    await saveImage();

    _savedImage2x = await File(
      iconPathForSize(twoX: true),
    ).readAsBytes();

    _savedImage = await File(
      iconPathForSize(twoX: false),
    ).readAsBytes();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _saveIcon,
              child: const Text('Save DMG Background'),
            ),
            ElevatedButton(
              onPressed: () => showFontDialog(context: context),
              child: const Text('Choose Font'),
            ),
            const SizedBox(height: 20),
            if (_savedImage2x != null) Image.memory(_savedImage2x!),
            const SizedBox(height: 20),
            if (_savedImage != null) Image.memory(_savedImage!),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateIconData({
    required bool twoX,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    if (_image != null) {
      DmgPainter.paintDmg(
        canvas: canvas,
        image: _image!,
        twoX: twoX,
      );
    }

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(
      DmgPainter.dmgSize(twoX: twoX).width.toInt(),
      DmgPainter.dmgSize(twoX: twoX).height.toInt(),
    );

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveImage() async {
    var imageData = await _generateIconData(twoX: false);

    File file = File(iconPathForSize(twoX: false));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );

    imageData = await _generateIconData(twoX: true);
    file = File(iconPathForSize(twoX: true));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );
  }

  String iconPathForSize({
    required bool twoX,
  }) {
    const iconBasePath = './icons/background';
    final numX = twoX ? '@2x' : '@1x';

    return '$iconBasePath$numX.png';
  }
}

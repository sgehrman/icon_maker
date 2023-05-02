import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/dmg_painter.dart';
import 'package:icon_maker/image_processor.dart';
import 'package:image/image.dart' as img;

class DmgScreen extends StatefulWidget {
  @override
  State<DmgScreen> createState() => _DmgScreenState();
}

class _DmgScreenState extends State<DmgScreen> {
  Uint8List? savedImage;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: MaterialSvgs.riceBowlSharp,
      width: 55,
      color: Colors.white,
    );

    _image = await ImageProcessor.bytesToImage(iconData);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveIcon() async {
    await saveImage();

    savedImage = await File(
      iconPathForSize(size: DmgPainter.dmgSize),
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
            const SizedBox(height: 20),
            if (savedImage != null) Image.memory(savedImage!),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateIconData() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    if (_image != null) {
      DmgPainter.paintDmg(
        canvas: canvas,
        size: DmgPainter.dmgSize,
        image: _image!,
      );
    }

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(
      DmgPainter.dmgSize.width.toInt(),
      DmgPainter.dmgSize.height.toInt(),
    );

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveImage() async {
    final imageData = await _generateIconData();

    final File file = File(iconPathForSize(size: DmgPainter.dmgSize));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );

    await saveImageWithSize(imageData: imageData, size: DmgPainter.dmgSize);
  }

  String iconPathForSize({
    required Size size,
  }) {
    return './icons/background.png';
  }

  Future<void> saveImageWithSize({
    required Uint8List imageData,
    required Size size,
    bool ico = false,
  }) async {
    final img.Image image = img.decodeImage(imageData)!;

    try {
      final Uint8List data = img.encodePng(image, level: 0);

      final File file = File(iconPathForSize(size: size));
      file.createSync(recursive: true);
      await file.writeAsBytes(
        data,
      );
    } catch (err) {
      print(err);
    }
  }
}

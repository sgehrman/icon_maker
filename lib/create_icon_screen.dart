import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/icon_painter.dart';
import 'package:icon_maker/icon_widget.dart';
import 'package:icon_maker/image_processor.dart';
import 'package:icon_maker/tray_icon.dart';
import 'package:image/image.dart' as img;

class KreateIconScreen extends StatefulWidget {
  @override
  State<KreateIconScreen> createState() => _KreateIconScreenState();
}

class _KreateIconScreenState extends State<KreateIconScreen> {
  Uint8List? savedImage;
  ui.Image? _image;
  Uint8List? _favIcon;

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: MaterialSvgs.surfingBaseline,
      width: IconPainter.svgIconSize.toInt(),
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
      iconPathForSize(size: IconPainter.baseIconSize.toInt()),
    ).readAsBytes();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveFavIcon() async {
    // ----------------------------------------------------------------
    // generate all combos

    for (final mode in TrayIconMode.values) {
      for (final size in TrayIconSize.values) {
        final TrayIcon tmp = TrayIcon(size, mode);
        await tmp.saveFavIcon();
      }
    }

    // ----------------------------------------------------------------

    final TrayIcon trIcn = TrayIcon(TrayIconSize.large, TrayIconMode.cyan);
    _favIcon = await File(
      trIcn.faviconPath,
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
              child: const Text('Save Icon'),
            ),
            ElevatedButton(
              onPressed: _saveFavIcon,
              child: const Text('Save FavIcon'),
            ),
            const SizedBox(height: 20),
            IconWidget(),
            const SizedBox(height: 20),
            if (savedImage != null) Image.memory(savedImage!),
            if (_favIcon != null) Image.memory(_favIcon!),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateIconData(double size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    IconPainter.paintIcon(
      canvas,
      Size(size, size),
      _image,
    );

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage = await pict.toImage(size.toInt(), size.toInt());

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveImage() async {
    final imageData = await _generateIconData(IconPainter.baseIconSize);

    final File file =
        File(iconPathForSize(size: IconPainter.baseIconSize.toInt()));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );

    await saveImageWithSize(imageData: imageData, size: 16);
    await saveImageWithSize(imageData: imageData, size: 32);
    await saveImageWithSize(imageData: imageData, size: 64);
    await saveImageWithSize(imageData: imageData, size: 128);
    await saveImageWithSize(imageData: imageData, size: 256);
    await saveImageWithSize(imageData: imageData, size: 512);

    // windows icon
    await saveImageWithSize(
      imageData: imageData,
      size: 256,
      ico: true,
    );
  }

  String iconPathForSize({
    required int size,
    bool ico = false,
  }) {
    const iconBasePath = './app_icon_';
    final ext = ico ? '.ico' : '.png';

    return '$iconBasePath$size$ext';
  }

  Future<void> saveImageWithSize({
    required Uint8List imageData,
    required int size,
    bool ico = false,
  }) async {
    img.Image image = img.decodeImage(imageData)!;

    // shrink image
    image = img.copyResize(
      image,
      width: size,
      interpolation: img.Interpolation.average,
    );

    try {
      Uint8List data;
      if (ico) {
        data = img.encodeIco(image);
      } else {
        // level: 0 is no compression
        data = img.encodePng(image, level: 0);
      }

      final File file = File(iconPathForSize(size: size, ico: ico));
      file.createSync(recursive: true);
      await file.writeAsBytes(
        data,
      );
    } catch (err) {
      print(err);
    }
  }
}

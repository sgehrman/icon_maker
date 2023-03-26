import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/image_processor.dart';

// Up to a maximum of 5
// 1280x800 or 640x400
// JPEG or 24-bit PNG (no alpha)

// At least one is required
// 440x280
// JPEG or 24-bit PNG (no alpha)

// 1400x560 Canvas
// JPEG or 24-bit PNG (no alpha)

class ScreenshotScreen extends StatefulWidget {
  @override
  State<ScreenshotScreen> createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  Uint8List? _savedImage;
  Uint8List? _sourceImage;
  ui.Image? _image;
  final int _height = 800;
  final int _width = 1280;

  Future<void> _loadImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file != null) {
      final Uint8List imageData = await file.readAsBytes();

      _image = await ImageProcessor.bytesToImage(imageData);
      _sourceImage = imageData;

      if (mounted) {
        setState(() {});
      }
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
              onPressed: _loadImage,
              child: const Text('Load Source Image'),
            ),
            ElevatedButton(
              onPressed: _saveIcon,
              child: Text('Save ${_width}x$_height'),
            ),
            const SizedBox(height: 50),
            if (_sourceImage != null) Image.memory(_sourceImage!),
            const SizedBox(height: 50),
            if (_savedImage != null) Image.memory(_savedImage!),
          ],
        ),
      ),
    );
  }

  void _paintIcon(
    Canvas canvas,
    Size size,
    ui.Image? image,
  ) {
    final realSize = size;
    final scale = size.width / realSize.width;

    canvas.scale(scale);

    final rect = Offset.zero & realSize;

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: size.width,
      height: size.height,
    );

    if (image != null) {
      // this gets rid of frame? not sure what is happening
      // canvas.saveLayer(rect, Paint());
      canvas.saveLayer(imageRect.deflate(6), Paint());

      canvas.drawRect(
        imageRect,
        Paint()..color = Colors.orange,
      );

      canvas.drawImage(image, imageRect.topLeft, Paint());

      canvas.restore();
    }
  }

  Future<Uint8List> _generateImageData(Size size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    _paintIcon(
      canvas,
      size,
      _image,
    );

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage =
        await pict.toImage(size.width.toInt(), size.height.toInt());

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> _saveIcon() async {
    await _saveImage();

    _savedImage = await File(
      iconPathForSize(size: Size(_width.toDouble(), _height.toDouble())),
    ).readAsBytes();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveImage() async {
    final imageData = await _generateImageData(
      Size(
        _width.toDouble(),
        _height.toDouble(),
      ),
    );

    final File file = File(
      iconPathForSize(
        size: Size(
          _width.toDouble(),
          _height.toDouble(),
        ),
      ),
    );
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );
  }

  String iconPathForSize({
    required Size size,
  }) {
    const iconBasePath = './screenshot_';

    return '$iconBasePath$size.png';
  }

  // Future<void> _saveImageWithSize({
  //   required Uint8List imageData,
  //   required int size,
  // }) async {
  //   img.Image image = img.decodeImage(imageData)!;

  //   // shrink image
  //   image = img.copyResize(
  //     image,
  //     width: size,
  //     interpolation: img.Interpolation.average,
  //   );

  //   try {
  //     Uint8List data;

  //     // level: 0 is no compression
  //     data = img.encodePng(image, level: 0);

  //     final File file = File(iconPathForSize(size: size));
  //     file.createSync(recursive: true);
  //     await file.writeAsBytes(
  //       data,
  //     );
  //   } catch (err) {
  //     print(err);
  //   }
  // }
}

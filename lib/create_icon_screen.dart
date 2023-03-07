import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

const double _kWidth = 1024;

class CreateIconScreen extends StatefulWidget {
  @override
  State<CreateIconScreen> createState() => _CreateIconScreenState();

  static void paintIcon(
    Canvas canvas,
    Size size,
    Color color,
    ui.Image? image,
  ) {
    const realSize = Size(_kWidth, _kWidth);

    final scale = size.width / realSize.width;

    canvas.scale(scale);

    final rect = Offset.zero & realSize;

    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color;

    final Path path = Path();

    path.moveTo(rect.topLeft.dx, rect.topLeft.dy);
    path.lineTo(rect.topRight.dx, rect.centerRight.dy);
    path.lineTo(rect.bottomLeft.dx, rect.bottomLeft.dy);

    canvas.drawPath(path, paint);

    const color2 = Color.fromRGBO(12, 43, 64, 1);
    const color22 = Color.fromRGBO(12, 123, 124, 1);

    final Paint paint2 = Paint();
    paint2.shader = const LinearGradient(
      colors: [color2, color22],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    final double kIconSize = realSize.width / 2;
    final Rect iconRect = Offset.zero & Size(kIconSize, kIconSize);

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: iconRect.width,
      height: iconRect.height,
    );

    if (image != null) {
      canvas.drawImage(image, imageRect.topLeft, paint2);
    }
  }
}

class _CreateIconScreenState extends State<CreateIconScreen> {
  String iconPath = './icon.png';
  Uint8List? savedImage;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: MaterialSvgs.importContactsSharp,
      width: _kWidth ~/ 2,
      color: Colors.black,
    );

    ui.decodeImageFromList(iconData, (ui.Image img) {
      _image = img;

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await saveImage();

                savedImage = await File(iconPath).readAsBytes();

                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text('Save Icon'),
            ),
            if (savedImage != null) Image.memory(savedImage!),
            Container(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(width: 6)),
              ),
              height: 256,
              width: 256,
              child: ClipRect(
                child: CustomPaint(
                  painter: TrianglePainter(
                    color: Colors.cyan,
                    image: _image,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveImage() async {
    final File file = File(iconPath);
    file.createSync(recursive: true);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    CreateIconScreen.paintIcon(
      canvas,
      const Size(_kWidth, _kWidth),
      Colors.cyan,
      _image,
    );

    final ui.Picture pict = recorder.endRecording();

    final ui.Image resultImage =
        await pict.toImage(_kWidth.toInt(), _kWidth.toInt());

    final ByteData data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();

    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}

// =========================================================

class TrianglePainter extends CustomPainter {
  const TrianglePainter({
    required this.color,
    required this.image,
  });

  final Color color;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    CreateIconScreen.paintIcon(canvas, size, color, image);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

// ==============================================================

class ImageProcessor {
  static Future<Uint8List> svgToPng({
    required String svg,
    required int width,
    Color? color,
  }) {
    return _jovialSvgToPng(
      svg: svg,
      scaleTo: ui.Size(
        width.toDouble(),
        width.toDouble(),
      ),
      color: color,
    );
  }

  static Future<Uint8List> _jovialSvgToPng({
    required String svg,
    ui.Size? scaleTo,
    Color? color,
  }) async {
    try {
      ScalableImage si = ScalableImage.fromSvgString(
        svg,
        // currentColor: color,
      );

      // currentColor above doesn't work?
      if (color != null) {
        si = si.modifyTint(
          newTintMode: BlendMode.srcIn,
          newTintColor: color,
        );
      }

      await si.prepareImages();

      final vpSize = si.viewport;

      final recorder = ui.PictureRecorder();
      final ui.Canvas c = ui.Canvas(recorder);

      if (scaleTo != null) {
        c.scale(scaleTo.width / vpSize.width, scaleTo.height / vpSize.height);
      }
      si.paint(c);
      si.unprepareImages();

      final size = scaleTo ?? ui.Size(vpSize.width, vpSize.height);
      final ui.Picture pict = recorder.endRecording();

      final ui.Image rendered =
          await pict.toImage(size.width.round(), size.height.round());

      final ByteData? bd = await rendered.toByteData(
        format: ui.ImageByteFormat.png,
      );

      pict.dispose();
      rendered.dispose();

      if (bd != null) {
        return bd.buffer.asUint8List();
      }
    } catch (err) {
      print('svgToPngBytes: Error = $err');
    }

    return Uint8List(0);
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

const double _kWidth = 1024;
const double _iconSize = 600;

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

    final Rect imageRect = Rect.fromCenter(
      center: rect.center,
      width: _iconSize,
      height: _iconSize,
    );

    const startColor = Color.fromRGBO(55, 55, 55, 1);
    const endColor = Color.fromRGBO(105, 155, 222, 1);

    final Paint gradientPaint = Paint();
    gradientPaint.shader = const LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    gradientPaint.isAntiAlias = true;

    final Paint blendPaint = Paint();
    blendPaint.blendMode = ui.BlendMode.dstIn;
    blendPaint.isAntiAlias = true;

    // ------------------------------------------------
    // draw oval
    final ovalRect = rect.deflate(12);

    canvas.drawShadow(
      Path()..addOval(ovalRect),
      Colors.black,
      12,
      true,
    );

    final ovalPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color;

    ovalPaint.shader = RadialGradient(
      colors: [Colors.white, color],
    ).createShader(ovalRect);
    canvas.drawOval(ovalRect, ovalPaint);

    final ovalLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..color = startColor.mix(endColor, 0.4)!;

    canvas.drawPath(Path()..addOval(ovalRect.deflate(30)), ovalLinePaint);

    // ------------------------------------------------

    if (image != null) {
      // this gets rid of frame? not sure what is happening
      // canvas.saveLayer(rect, Paint());
      canvas.saveLayer(imageRect.deflate(6), Paint());

      canvas.drawRect(imageRect, gradientPaint);
      canvas.drawImage(image, imageRect.topLeft, blendPaint);

      canvas.restore();
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
      svg: MaterialSvgs.surfingBaseline,
      width: _iconSize.toInt(),
      color: Colors.white,
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
      final ScalableImage si = ScalableImage.fromSvgString(
        svg,
      );

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

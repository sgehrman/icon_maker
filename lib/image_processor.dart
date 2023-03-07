import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

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

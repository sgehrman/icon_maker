import 'dart:async';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/icon_painter.dart';

class IconWidget extends StatefulWidget {
  @override
  State<IconWidget> createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
  final _svgCompleter = Completer<ui.Image>();

  @override
  void initState() {
    super.initState();

    _setup();
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: MaterialSvgs.surfingBaseline,
      size: IconPainter.svgIconSize,
      color: Colors.white,
    );

    final img = await ImageProcessor.bytesToImage(iconData.bytes);

    _svgCompleter.complete(img);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _svgCompleter.future,
      builder: (context, image) {
        return Container(
          decoration: const BoxDecoration(
            border: Border.fromBorderSide(BorderSide(width: 6)),
          ),
          height: 256,
          width: 256,
          child: ClipRect(
            child: CustomPaint(
              painter: IconPainter(
                image: image.data,
              ),
            ),
          ),
        );
      },
    );
  }
}

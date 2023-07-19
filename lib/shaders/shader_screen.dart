import 'dart:io';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:icon_maker/shaders/shader_widget.dart';
import 'package:icon_maker/shaders/show_qrcode_dialog.dart';

GlobalKey keyOne = GlobalKey();
GlobalKey keyTwo = GlobalKey();

class ShaderScreen extends StatefulWidget {
  @override
  State<ShaderScreen> createState() => _ShaderScreenState();
}

class _ShaderScreenState extends State<ShaderScreen> {
  @override
  void initState() {
    super.initState();
  }

  String iconPathForSize() {
    const iconBasePath = './icons/shaders/shader';

    return '$iconBasePath.png';
  }

  Future<void> _captureSocialPng(GlobalKey key) {
    return Future.delayed(const Duration(milliseconds: 20), () async {
      final RenderRepaintBoundary? boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary?;

      final ui.Image image = await boundary!.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageData = byteData!.buffer.asUint8List();

      final File file = File(iconPathForSize());
      file.createSync(recursive: true);

      await file.writeAsBytes(
        imageData,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            DFButton(
              onPressed: () => showQRCodeDialog(
                context: context,
                title: 'QRCode',
                data: 'https://store.deckr.surf',
              ),
              label: 'QRCode',
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _captureSocialPng(keyOne),
              child: RepaintBoundary(
                key: keyOne,
                child: const SizedBox(
                  height: 512,
                  width: 512,
                  child: ShaderWidget(
                    assetPath: 'shaders/starTunnel.glsl',
                    animate: true,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () => _captureSocialPng(keyTwo),
              child: RepaintBoundary(
                key: keyTwo,
                child: const SizedBox(
                  height: 512,
                  width: 512,
                  child: ShaderWidget(
                    assetPath: 'shaders/coloredCells.glsl',
                    animate: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

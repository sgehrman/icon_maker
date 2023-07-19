import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/utils/widget_dialog.dart';
import 'package:image/image.dart' as img;

void showQRCodeDialog({
  required BuildContext context,
  required String title,
  required String data,
}) {
  widgetDialog(
    context: context,
    title: title,
    dialogWidth: 700,
    builder: WidgetDialogContentBuilder(
      (keyboardNotifier, titleNotifier) => [
        _QRCodeDialogWidget(
          data: data,
        ),
        const SizedBox(height: 10),
        TextWithLinks(
          data,
          humanize: true,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    ),
  );
}

class _QRCodeDialogWidget extends StatelessWidget {
  const _QRCodeDialogWidget({required this.data});

  final String data;

  String iconPathForSize() {
    const iconBasePath = './icons/shaders/qrcode';

    return '$iconBasePath.png';
  }

  @override
  Widget build(BuildContext context) {
    const double size = 128;

    return Center(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(60),
            child: BarcodeWidget(
              height: size,
              width: size,
              backgroundColor: Colors.white,
              barcode: Barcode.qrCode(),
              padding: const EdgeInsets.all(20),
              data: data,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: FloatingActionButton(
              child: const Icon(Icons.download),
              onPressed: () async {
                final image =
                    img.Image(height: size.toInt(), width: size.toInt());

                img.fill(image, color: img.ColorUint8.rgba(255, 255, 255, 255));

                _drawBarcodeToImage(image, Barcode.qrCode(), data);

                final imageData = img.encodePng(image, level: 9);

                final File file = File(iconPathForSize());
                file.createSync(recursive: true);

                await file.writeAsBytes(
                  imageData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================

void _drawBarcodeToImage(
  img.Image image,
  Barcode barcode,
  String data,
) {
  const border = 8;

  const x = border;
  const y = border;

  final width = image.width - (border * 2);
  final height = image.height - (border * 2);

  final recipe = barcode.make(
    data,
    width: width.toDouble(),
    height: height.toDouble(),
  );

  _drawBarcode(image, recipe, x, y);
}

void _drawBarcode(
  img.Image image,
  Iterable<BarcodeElement> recipe,
  int x,
  int y,
) {
  for (final elem in recipe) {
    if (elem is BarcodeBar) {
      if (elem.black) {
        img.fillRect(
          image,
          x1: (x + elem.left).round(),
          y1: (y + elem.top).round(),
          x2: (x + elem.right).round(),
          y2: (y + elem.bottom).round(),
          color: img.ColorUint8.rgba(0, 0, 0, 255),
        );
      }
    } else if (elem is BarcodeText) {
      print('text?');
    }
  }
}

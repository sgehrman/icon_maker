import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/icon_painter.dart';
import 'package:icon_maker/icon_widget.dart';
import 'package:icon_maker/screenshot/screenshot_assets.dart';
import 'package:icon_maker/tray_icon.dart';
import 'package:icon_maker/utils/theme_prefs.dart';
import 'package:image/image.dart' as img;

class IconScreen extends StatefulWidget {
  @override
  State<IconScreen> createState() => _IconScreenState();
}

class _IconScreenState extends State<IconScreen> {
  Uint8List? savedImage;
  ui.Image? _image;
  Uint8List? _favIcon;
  late ScreenshotAssets assets;

  @override
  void initState() {
    super.initState();

    _setup();

    assets = ScreenshotAssets(
      () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _setup() async {
    final iconData = await ImageProcessor.svgToPng(
      svg: IconPainter.safariMode
          ? MaterialSvgs.extensionBaseline
          : MaterialSvgs.surfingBaseline,
      size: IconPainter.svgIconSize,
      color: Colors.white,
    );

    _image = await ImageProcessor.bytesToImage(iconData.bytes);

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
        final tmp = TrayIcon(size, mode);
        await tmp.saveFavIcon();
      }
    }

    // ----------------------------------------------------------------

    final trIcn = TrayIcon(TrayIconSize.large, TrayIconMode.cyan);
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveFavIcon,
              child: const Text('Save FavIcon'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveSafariIconImages,
              child: const Text('Save Safari Icons'),
            ),
            ElevatedButton(
              onPressed: savePathFinderIcon,
              child: const Text('Path Finder Icon'),
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

  Future<Uint8List> _generateIconData({
    required bool insetImage,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = IconPainter.baseIconSize;

    IconPainter.paintIcon(
      canvas: canvas,
      size: const Size(size, size),
      image: _image,
      insetImage: insetImage,
    );

    final pict = recorder.endRecording();

    final resultImage = await pict.toImage(size.toInt(), size.toInt());

    final data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();
    pict.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveImage() async {
    final imageData = await _generateIconData(insetImage: true);
    final imageDataNoInset = await _generateIconData(insetImage: false);

    final file = File(iconPathForSize(size: IconPainter.baseIconSize.toInt()));
    file.createSync(recursive: true);

    await file.writeAsBytes(
      imageData,
    );

    await saveImageWithSize(imageData: imageDataNoInset, size: 16);
    await saveImageWithSize(imageData: imageDataNoInset, size: 32);
    await saveImageWithSize(imageData: imageData, size: 64);
    await saveImageWithSize(imageData: imageData, size: 128);
    await saveImageWithSize(imageData: imageData, size: 192);
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
    const iconBasePath = './icons/app_icon_';
    final ext = ico ? '.ico' : '.png';

    return '$iconBasePath$size$ext';
  }

  Future<void> saveImageWithSize({
    required Uint8List imageData,
    required int size,
    bool ico = false,
  }) async {
    var image = img.decodeImage(imageData)!;

    // shrink image
    image = img.copyResize(
      image,
      width: size,
      interpolation: img.Interpolation.average,
    );

    try {
      Uint8List data;
      if (ico) {
        data = img.encodeIco(image, singleFrame: true);
      } else {
        // level: 0 is no compression
        data = img.encodePng(image, level: 0);
      }

      final file = File(iconPathForSize(size: size, ico: ico));
      file.createSync(recursive: true);
      await file.writeAsBytes(
        data,
      );
    } catch (err) {
      print(err);
    }
  }

  // ============================================================
  // safari images

  String iconPathForSafari({
    required int size,
    bool twoX = false,
  }) {
    const iconBasePath = './icons/mac-icon-';
    final numX = twoX ? '@2x' : '@1x';

    return '$iconBasePath$size$numX.png';
  }

  Future<void> saveSafariIconImages() async {
    final imageData = await _generateIconData(insetImage: true);
    final imageDataNoInset = await _generateIconData(insetImage: false);

    await saveSafariImageWithSize(imageData: imageDataNoInset, size: 16);
    await saveSafariImageWithSize(imageData: imageDataNoInset, size: 32);
    await saveSafariImageWithSize(imageData: imageData, size: 128);
    await saveSafariImageWithSize(imageData: imageData, size: 256);
    await saveSafariImageWithSize(imageData: imageData, size: 512);
  }

  Future<void> saveSafariImageWithSize({
    required Uint8List imageData,
    required int size,
  }) async {
    await doSaveSafariImageWithSize(
      imageData: imageData,
      size: size,
      twoX: false,
    );

    await doSaveSafariImageWithSize(
      imageData: imageData,
      size: size,
      twoX: true,
    );
  }

  Future<void> doSaveSafariImageWithSize({
    required Uint8List imageData,
    required int size,
    required bool twoX,
  }) async {
    var image = img.decodeImage(imageData)!;

    // shrink image
    image = img.copyResize(
      image,
      width: twoX ? size * 2 : size,
      interpolation: img.Interpolation.average,
    );

    try {
      // level: 0 is no compression
      final data = img.encodePng(image, level: 0);

      final file = File(iconPathForSafari(size: size, twoX: twoX));
      file.createSync(recursive: true);
      await file.writeAsBytes(
        data,
      );
    } catch (err) {
      print(err);
    }
  }

  // ============================================================

  Future<void> savePathFinderIcon() async {
    savedImage = await _generatePathFinderIconData();
    await saveImageWithSize(imageData: savedImage!, size: 1024);

    if (mounted) {
      setState(() {});
    }
  }

  Future<Uint8List> _generatePathFinderIconData() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double size = 1024;

    final imageRect = Offset.zero & const Size(size, size);

    final image = await assets.pathFinderImage;

    canvas.drawImage(image, imageRect.topLeft, Paint());

    // --------------------------------------------------------
    // filled rect
    const hInset = 168.0;
    const vInset = 160.0;
    const rectHeight = 180.0;
    const fontSize = 120.0;

    const filledRect = Rect.fromLTWH(
        hInset, size - rectHeight - vInset, size - (hInset * 2), rectHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(filledRect, const Radius.circular(42)),
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // --------------------------------------------------------
    // text

    final textPainter = TextPainter(
      text: TextSpan(
        text: '2  Year'.toUpperCase(),
        style: FontUtils.styleWithGoogleFont(
          // 'Alatsi',
          ThemePrefs().font.value,
          // 'Roboto',
          const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),

        // style: TextStyle(fontSize: 82, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size);

    final horizOffset = size / 2 - textPainter.width / 2;
    final vertOffset =
        filledRect.top + (filledRect.height / 2) - (textPainter.height / 2);

    textPainter.paint(canvas, Offset(horizOffset, vertOffset));

    final pict = recorder.endRecording();

    final resultImage = await pict.toImage(size.toInt(), size.toInt());

    final data =
        (await resultImage.toByteData(format: ui.ImageByteFormat.png))!;

    resultImage.dispose();
    pict.dispose();

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

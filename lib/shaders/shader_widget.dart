import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ShaderWidget extends StatefulWidget {
  const ShaderWidget({
    required this.assetPath,
    required this.animate,
    this.params = const [],
    super.key,
  });

  final String assetPath;
  final bool animate;
  final List<double> params;

  @override
  State<ShaderWidget> createState() => _ShaderWidgetState();
}

class _ShaderWidgetState extends State<ShaderWidget>
    with SingleTickerProviderStateMixin {
  double time = 0;

  Ticker? _ticker;

  @override
  void initState() {
    super.initState();

    // too slow on mobile, just have it draw one frame an no more
    if (widget.animate) {
      _ticker = createTicker((elapsed) {
        time += 0.015;
        setState(() {});
      });
      _ticker?.start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          return ShaderBuilder(
            assetKey: widget.assetPath,
            child: SizedBox(
              width: size.width,
              height: size.height,
            ),
            (context, shader, child) {
              return AnimatedSampler(
                child: child!,
                (image, size, canvas) {
                  shader
                    ..setFloat(0, time)
                    ..setFloat(1, size.width)
                    ..setFloat(2, size.height)
                    ..setImageSampler(0, image);

                  var index = 3;
                  for (final p in widget.params) {
                    shader.setFloat(index++, p);
                  }

                  canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:flutter/material.dart';

class SvgPreviewScreen extends StatefulWidget {
  @override
  State<SvgPreviewScreen> createState() => _SvgPreviewScreenState();
}

class _SvgPreviewScreenState extends State<SvgPreviewScreen> {
  List<Widget> _svgButtons() {
    return [
      DFButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) {
                return SvgScreen(
                  color:
                      Utils.isDarkMode(context) ? Colors.white : Colors.black,
                  // source: SVGSource.material,
                );
              },
            ),
          );
        },
        label: 'Material Icons',
      ),
      const SizedBox(height: 10),
      DFButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) {
                return SvgScreen(
                  color:
                      Utils.isDarkMode(context) ? Colors.white : Colors.black,
                  source: SVGSource.bootstrap,
                );
              },
            ),
          );
        },
        label: 'Bootstrap Icons',
      ),
      const SizedBox(height: 10),
      DFButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) {
                return SvgScreen(
                  color:
                      Utils.isDarkMode(context) ? Colors.white : Colors.black,
                  source: SVGSource.fontawesome,
                );
              },
            ),
          );
        },
        label: 'Fontawesome Icons',
      ),
      const SizedBox(height: 10),
      DFButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) {
                return SvgScreen(
                  color:
                      Utils.isDarkMode(context) ? Colors.white : Colors.black,
                  source: SVGSource.community,
                );
              },
            ),
          );
        },
        label: 'Community Icons',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          ..._svgButtons(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

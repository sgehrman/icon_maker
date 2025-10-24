import 'package:dfc_flutter/dfc_flutter.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/dmg_screen.dart';
import 'package:icon_maker/icon_screen.dart';
import 'package:icon_maker/screenshot/screenshot_screen.dart';
import 'package:icon_maker/shaders/shader_screen.dart';
import 'package:icon_maker/svg_screen.dart';

void main() async {
  // needed for tooltips pref
  await HiveUtils.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromRGBO(215, 225, 255, 1),
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.alwaysVisible,
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _body = IconScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              _body = ShaderScreen();

              setState(() {});
            },
            icon: const Icon(Icons.bike_scooter),
          ),
          IconButton(
            onPressed: () {
              _body = ScreenshotScreen();

              setState(() {});
            },
            icon: const Icon(Icons.kebab_dining),
          ),
          IconButton(
            onPressed: () {
              _body = IconScreen();

              setState(() {});
            },
            icon: const Icon(Icons.account_balance_outlined),
          ),
          IconButton(
            onPressed: () {
              _body = DmgScreen();

              setState(() {});
            },
            icon: const Icon(Icons.access_alarm),
          ),
          IconButton(
            onPressed: () {
              _body = SvgPreviewScreen();

              setState(() {});
            },
            icon: const Icon(Icons.baby_changing_station_sharp),
          ),
        ],
      ),
      body: _body,
    );
  }
}

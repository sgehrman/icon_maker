import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:flutter/material.dart';
import 'package:icon_maker/utils/theme_prefs.dart';
import 'package:icon_maker/utils/widget_dialog.dart';

Future<void> showFontDialog({
  required BuildContext context,
}) {
  return widgetDialog(
    context: context,
    title: 'Choose a Font',
    builder: WidgetDialogContentBuilder(
      (keyboardNotifier, titleNotifier) => [
        const SizedBox(
          height: 600,
          width: 400,
          child: _GoogleFontsWidget(),
        ),
      ],
    ),
  );
}

// ========================================================

class _FontObj {
  _FontObj({
    required this.name,
    required this.displayName,
    required this.fav,
    required this.firstChar,
  });

  final String name;
  final String displayName;
  final String firstChar;
  bool fav;
}

class _GoogleFontsWidget extends StatefulWidget {
  const _GoogleFontsWidget();

  @override
  _GoogleFontsWidgetState createState() => _GoogleFontsWidgetState();
}

class _GoogleFontsWidgetState extends State<_GoogleFontsWidget> {
  final ScrollController _scrollController = ScrollController();

  final _fontList = _buildFontList();

  static List<_FontObj> _buildFontList() {
    final List<String> gFonts = FontUtils.googleFonts();
    final List<String?> favs = Preferences().getFavoriteGoogleFonts();

    final result = <_FontObj>[];

    for (final f in gFonts) {
      final String fixed = f.replaceFirst('TextTheme', '');

      final bool fav = favs.contains(f);

      result.add(
        _FontObj(
          name: f,
          displayName: fixed.fromCamelCase(),
          fav: fav,
          firstChar: f.toUpperCase().firstChar,
        ),
      );
    }

    return result;
  }

  void _clickedItem(_FontObj fontObj) {
    setState(() {
      fontObj.fav = !fontObj.fav;

      // save in prefs
      final List<String> favs = Preferences().getFavoriteGoogleFonts();

      if (fontObj.fav) {
        favs.add(fontObj.name);
      } else {
        favs.remove(fontObj.name);
      }

      Preferences().setFavoriteGoogleFonts(favs);
    });
  }

  Widget _contents(Color? normalColor, String currentFont) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(height: 2),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: _fontList.length,
      itemBuilder: (context, index) {
        final fontObj = _fontList[index];

        return _FontItem(
          currentFont: currentFont,
          fontObj: fontObj,
          onPressed: () => _clickedItem(fontObj),
        );
      },
    );
  }

  // void _useDefault() {
  //   ThemePrefs().setGoogleFont(ThemePrefs.defaultFontName);

  //   // scroll to default
  //   int index = 0;
  //   for (int i = 0; i < _fontList.length; i++) {
  //     final font = _fontList[i];

  //     if (font.name == ThemePrefs.defaultFontName) {
  //       index = i;
  //       break;
  //     }
  //   }

  //   _scrollController.animateTo(
  //     50.0 * index, // <= bullshit, but not important, fix later
  //     duration: const Duration(seconds: 1),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final Color? normalColor = Theme.of(context).textTheme.bodyMedium!.color;

    return _contents(normalColor, ThemePrefs().font.value);
  }
}

// ======================================================

class _FontItem extends StatelessWidget {
  const _FontItem({
    required this.fontObj,
    required this.currentFont,
    required this.onPressed,
  });

  final _FontObj fontObj;
  final String currentFont;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleLarge!;

    // crashes web/canvaskit
    // https://github.com/material-foundation/flutter-packages/issues/399
    if (!Utils.isWeb) {
      style = FontUtils.styleWithGoogleFont(fontObj.name, style);
    }

    if (fontObj.name == currentFont) {
      style = style.copyWith(color: Theme.of(context).primaryColor);
    }

    // not using ListTile for speed
    // we use the itemExtent and add our own divider
    return InkWell(
      onTap: () {
        ThemePrefs().font.value = fontObj.name;
      },
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                fontObj.displayName,
                style: style,
              ),
            ),
          ),
          DFIconButton(
            iconSize: 18,
            onPressed: onPressed,
            icon: fontObj.fav
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.favorite_border,
                  ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:flutter/material.dart';

enum DialogResult {
  ok,
  canceled,
  error,
}

class BaseDialogRoute<T> extends ModalRoute<T> {
  BaseDialogRoute()
      : super(
          filter: ImageFilter.blur(
            sigmaX: 3,
            sigmaY: 3,
          ),
        );

  final _keyboardNotifier = ValueNotifier<bool>(false);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.5);

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final titleNotifier = ValueNotifier<String>(dialogTitle());
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.9,
          maxWidth: screenSize.width * 0.9,
        ),
        width: math.min(screenSize.width * 0.9, width()),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          // boxShadow: Styles.dialogShadows(context),
          border: const Border.fromBorderSide(
            BorderSide(),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(
                titleNotifier: titleNotifier,
                titleButton: titleButton(context),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: dialogWidget(
                    context,
                    _keyboardNotifier,
                    titleNotifier,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // override
  Widget dialogWidget(
    BuildContext context,
    ValueNotifier<bool> keyboardNotifier,
    ValueNotifier<String> titleNotifier,
  ) {
    return const Text('must override');
  }

  // override
  String dialogTitle() {
    return '';
  }

  // override to replace the close button
  Widget titleButton(BuildContext context) {
    final color = closeButtonColor(context);

    // if you want a close button, set the color
    if (color != null) {
      return DFIconButton(
        tooltip: 'Close',
        iconSize: 30,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.clear, color: color),
      );
    }

    return const NothingWidget();
  }

  // override, override to null to remove the X button
  Color? closeButtonColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  // override
  double width() {
    return 600;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedValue = Curves.easeOut.transform(animation.value) - 1.0;

    return Transform(
      transform: Matrix4.translationValues(0, -curvedValue * 200, 0),
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }
}

// ==========================================================
//      final title = dialogTitle();

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.titleNotifier,
    required this.titleButton,
  });

  final ValueNotifier<String> titleNotifier;
  final Widget titleButton;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: titleNotifier,
      builder: (context, value, child) {
        if (Utils.isNotEmpty(value)) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // should work without this, but seeing some slight bleed
              // on the corners over the border
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding:
                const EdgeInsets.only(left: 20, right: 14, top: 4, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                  ),
                ),
                titleButton,
              ],
            ),
          );
        }

        return const NothingWidget();
      },
    );
  }
}

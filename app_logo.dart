import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 320, this.compact = false, this.dark = false});

  final double width;
  final bool compact;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    const label = 'EA Language Hub. Aprenda. Traduza. Comunique.';
    if (compact) {
      return Semantics(
        label: label,
        image: true,
        child: SvgPicture.asset(
          'assets/images/logo_icon.svg',
          width: width,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(Icons.menu_book_rounded, size: width * .8),
        ),
      );
    }

    final markSize = width * .29;
    final titleColor = dark ? AppConstants.white : AppConstants.navy;
    final taglineColor = dark ? AppConstants.gold : const Color(0xFF64748B);
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SvgPicture.asset(
              'assets/images/logo_icon.svg',
              width: markSize,
              height: markSize,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => Icon(Icons.menu_book_rounded, size: markSize * .8),
            ),
            SizedBox(width: width * .035),
            Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('EA LANGUAGE', style: TextStyle(color: titleColor, fontSize: width < 300 ? 17 : 21, fontWeight: FontWeight.w800, letterSpacing: .9)),
              ),
              Text('HUB', style: TextStyle(color: titleColor, fontSize: width < 300 ? 17 : 21, fontWeight: FontWeight.w800, letterSpacing: 3.4, height: .95)),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(AppConstants.slogan, maxLines: 1, style: TextStyle(color: taglineColor, fontSize: width < 300 ? 8 : 10, fontWeight: FontWeight.w500)),
              ),
            ])),
          ]),
        ),
      ),
    );
  }
}

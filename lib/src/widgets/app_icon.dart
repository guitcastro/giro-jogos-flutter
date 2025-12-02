import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final String assetPath;

  const AppIcon({
    super.key,
    this.size = 24,
    this.color,
    this.assetPath = 'assets/images/logo-giro-menor.svg',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
    );
  }
}

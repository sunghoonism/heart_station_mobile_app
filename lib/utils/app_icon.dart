import 'package:flutter/material.dart';
import 'theme.dart';

class HeartIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const HeartIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.favorite,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
} 
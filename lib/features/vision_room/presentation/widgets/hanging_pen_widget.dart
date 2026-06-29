import 'package:flutter/material.dart';
import 'hanging_pen.dart';

class HangingPenWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isFocusMode;

  const HangingPenWidget({
    super.key,
    this.onTap,
    this.isFocusMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return const HangingPen();
  }
}

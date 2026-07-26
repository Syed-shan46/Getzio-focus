import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'procedural_wind_controller.dart';
import '../../providers/vision_room_providers.dart';

class RealisticStickyNoteWrapper extends ConsumerStatefulWidget {
  final String noteId;
  final Widget child;
  final Color paperColor;
  final bool isDragging;

  const RealisticStickyNoteWrapper({
    super.key,
    required this.noteId,
    required this.child,
    required this.paperColor,
    this.isDragging = false,
  });

  @override
  ConsumerState<RealisticStickyNoteWrapper> createState() => _RealisticStickyNoteWrapperState();
}

class _RealisticStickyNoteWrapperState extends ConsumerState<RealisticStickyNoteWrapper> with TickerProviderStateMixin {
  late int _seed;
  late double _weight;
  late double _stiffness;
  
  late AnimationController _interactionController;
  SpringSimulation? _springSimulation;
  
  late AnimationController _flutterController;
  
  bool _isDragging = false;
  double _interactionBend = 0.0;

  @override
  void initState() {
    super.initState();
    _seed = widget.noteId.hashCode;
    
    final random = Random(_seed);
    _weight = 0.8 + random.nextDouble() * 0.4;
    _stiffness = 0.05 + random.nextDouble() * 0.05;
    
    _interactionController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _interactionBend = _interactionController.value;
        });
      });
    
    _flutterController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 1500 + random.nextInt(1000))
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _interactionController.dispose();
    _flutterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RealisticStickyNoteWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
        _startDragBend();
      } else {
        _endDragBend();
      }
    }
  }

  void _startDragBend() {
    _isDragging = true;
    _interactionController.stop();
    _springSimulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 100, damping: 15),
      _interactionBend, 1.5, 0,
    );
    _interactionController.animateWith(_springSimulation!);
  }

  void _endDragBend() {
    _isDragging = false;
    _interactionController.stop();
    _springSimulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 150, damping: 8),
      _interactionBend, 0.0, 0.0,
    );
    _interactionController.animateWith(_springSimulation!);
  }
  @override
  Widget build(BuildContext context) {
    final windController = ref.watch(proceduralWindProvider);
    final isEditMode = ref.watch(editModeProvider);
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          windController,
          _flutterController,
        ]),
        builder: (context, child) {
          final windForce = windController.sampleWindForNote(_seed);
          
          final targetAngle = (windForce * 0.045) / _weight;
          final windBendX = (windForce * 0.6) / _weight; 
          final dragBendX = _interactionBend * 0.6;
          final flutter = sin(_flutterController.value * pi * 2) * 0.05 * windController.globalIntensity;
          
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.003) 
            ..rotateZ(targetAngle)
            ..rotateX(-windBendX - dragBendX) 
            ..rotateY(targetAngle * 0.8 + flutter); 
          final shadowBend = (windBendX.abs() + dragBendX).clamp(0.0, 1.0);
          
          // Calculate a 0.0 to 1.0 curl amount for the bottom right corner
          // based on how much the paper is bending + some continuous flutter
          final curlAmount = (shadowBend * 0.8 + flutter.abs() * 5).clamp(0.05, 1.0);
          
          return Transform(
            alignment: Alignment.topCenter,
            transform: transform,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35 - (shadowBend * 0.25)),
                    blurRadius: 8.0 + (shadowBend * 32.0),
                    spreadRadius: -1.0,
                    offset: Offset(
                      2.0 + (targetAngle * 10), 
                      6.0 + (shadowBend * 25.0)
                    ),
                  ),
                ],
              ),
              child: CustomPaint(
                foregroundPainter: CurledCornerPainter(
                  curlAmount: curlAmount,
                  paperColor: widget.paperColor,
                ),
                child: ClipPath(
                  clipper: CurledCornerClipper(curlAmount),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CurledCornerClipper extends CustomClipper<Path> {
  final double curlAmount;

  CurledCornerClipper(this.curlAmount);

  @override
  Path getClip(Size size) {
    final path = Path();
    final curlSize = size.width * 0.4 * curlAmount;
    
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curlSize);
    path.lineTo(size.width - curlSize, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CurledCornerClipper oldClipper) => oldClipper.curlAmount != curlAmount;
}

class CurledCornerPainter extends CustomPainter {
  final double curlAmount;
  final Color paperColor;

  CurledCornerPainter({required this.curlAmount, required this.paperColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (curlAmount <= 0.01) return;

    final curlSize = size.width * 0.4 * curlAmount;
    final p1 = Offset(size.width, size.height - curlSize);
    final p2 = Offset(size.width - curlSize, size.height);
    
    // The tip of the fold curves inwards
    final foldTip = Offset(size.width - curlSize * 0.85, size.height - curlSize * 0.85);

    // Shadow under the fold
    final shadowPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(foldTip.dx - (curlSize * 0.1), foldTip.dy + (curlSize * 0.1))
      ..close();
      
    canvas.drawShadow(shadowPath, Colors.black, 4.0 + (curlAmount * 6.0), false);

    // The curled back of the paper
    final foldPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..quadraticBezierTo(
        size.width - curlSize * 0.2, size.height - curlSize * 0.2, 
        foldTip.dx, foldTip.dy
      )
      ..close();

    final hsl = HSLColor.fromColor(paperColor);
    final backColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();

    final paint = Paint()
      ..color = backColor
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(foldPath, paint);
    
    // Add lighting/highlight to the curl curve
    final gradient = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [
        Colors.black.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.5),
      ],
    );
    
    final highlightPaint = Paint()
      ..shader = gradient.createShader(Rect.fromPoints(p1, foldTip))
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(foldPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CurledCornerPainter oldDelegate) => 
      oldDelegate.curlAmount != curlAmount || oldDelegate.paperColor != paperColor;
}

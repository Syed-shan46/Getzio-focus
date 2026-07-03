import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'due_date_progress_selector.dart';

class ImageDetailsModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const ImageDetailsModal({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Function(Map<String, dynamic> metadata) onSubmit,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => ImageDetailsModal(onSubmit: onSubmit),
    );
  }

  @override
  State<ImageDetailsModal> createState() => _ImageDetailsModalState();
}

class _ImageDetailsModalState extends State<ImageDetailsModal> {
  final _captionController = TextEditingController();
  DateTime? _selectedDueDate;
  double _selectedProgress = 0.0;
  String _selectedEmoji = 'globe';

  final List<String> _emojiOptions = [
    'globe',
    'heart',
    'star',
    'flame',
    'airplane',
    'camera',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit({
      'caption': _captionController.text.trim(),
      'emoji': _selectedEmoji,
      'progress': _selectedProgress,
      'dueDate': _selectedDueDate?.toIso8601String(),
      'isOnShelf': false,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'IMAGE VISION GOAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set Polaroid Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Caption text input
                const Text(
                  'Polaroid Caption',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLength: 32,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., Explore the world',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Custom hand-drawn Emoji Picker
                const Text(
                  'Choose Sketch Emoji',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _emojiOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final emoji = _emojiOptions[index];
                      final isSelected = _selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: CustomPaint(
                            size: const Size(22, 22),
                            painter: HandDrawnEmojiPainter(
                              emoji,
                              color: isSelected ? const Color(0xFF10B981) : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Due Date And Progress selectors
                DueDateAndProgressSelector(
                  selectedDate: _selectedDueDate,
                  currentProgress: _selectedProgress,
                  accentColor: const Color(0xFF10B981),
                  onDateChanged: (d) => setState(() => _selectedDueDate = d),
                  onProgressChanged: (p) => setState(() => _selectedProgress = p),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Skip: submit only empty details
                          widget.onSubmit({
                            'caption': '',
                            'emoji': 'globe',
                            'progress': 0.0,
                            'dueDate': null,
                            'isOnShelf': false,
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Save Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HandDrawnEmojiPainter extends CustomPainter {
  final String emojiType;
  final Color color;

  HandDrawnEmojiPainter(this.emojiType, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    switch (emojiType) {
      case 'globe':
        final path = Path();
        // Slightly imperfect circle (hand-drawn circle)
        path.moveTo(cx + w * 0.42, cy);
        path.quadraticBezierTo(cx + w * 0.4, cy - h * 0.38, cx, cy - h * 0.42);
        path.quadraticBezierTo(cx - w * 0.38, cy - h * 0.4, cx - w * 0.42, cy);
        path.quadraticBezierTo(cx - w * 0.4, cy + h * 0.38, cx, cy + h * 0.42);
        path.quadraticBezierTo(cx + w * 0.38, cy + h * 0.4, cx + w * 0.42, cy);

        // Vertical lines (meridians)
        path.moveTo(cx, cy - h * 0.42);
        path.quadraticBezierTo(cx - w * 0.20, cy + h * 0.02, cx, cy + h * 0.42);
        path.moveTo(cx, cy - h * 0.42);
        path.quadraticBezierTo(cx + w * 0.20, cy - h * 0.02, cx, cy + h * 0.42);
        // Center vertical line (axis/meridian)
        path.moveTo(cx, cy - h * 0.42);
        path.lineTo(cx, cy + h * 0.42);

        // Horizontal lines (equator & parallels)
        path.moveTo(cx - w * 0.42, cy);
        path.quadraticBezierTo(cx + w * 0.02, cy + h * 0.05, cx + w * 0.42, cy); // Equator
        
        path.moveTo(cx - w * 0.35, cy - h * 0.2);
        path.quadraticBezierTo(cx, cy - h * 0.15, cx + w * 0.35, cy - h * 0.2);
        
        path.moveTo(cx - w * 0.35, cy + h * 0.2);
        path.quadraticBezierTo(cx, cy + h * 0.25, cx + w * 0.35, cy + h * 0.2);

        canvas.drawPath(path, paint);
        break;

      case 'heart':
        final path = Path();
        path.moveTo(cx, cy + h * 0.32);
        // Left curve
        path.cubicTo(
          cx - w * 0.48, cy - h * 0.1,
          cx - w * 0.32, cy - h * 0.45,
          cx, cy - h * 0.25,
        );
        // Right curve
        path.cubicTo(
          cx + w * 0.32, cy - h * 0.45,
          cx + w * 0.48, cy - h * 0.1,
          cx, cy + h * 0.32,
        );
        canvas.drawPath(path, paint);
        break;

      case 'star':
        final path = Path();
        const double rOuter = 10.5;
        const double rInner = 4.5;
        for (int i = 0; i < 10; i++) {
          final double angle = (i * pi / 5) - pi / 2;
          final double r = i.isEven ? rOuter : rInner;
          final double x = cx + r * cos(angle);
          final double y = cy + r * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'flame':
        final path = Path();
        path.moveTo(cx, cy + h * 0.38);
        path.cubicTo(cx - w * 0.35, cy + h * 0.38, cx - w * 0.4, cy, cx - w * 0.15, cy - h * 0.15);
        path.cubicTo(cx - w * 0.25, cy - h * 0.32, cx, cy - h * 0.45, cx, cy - h * 0.45);
        path.cubicTo(cx + w * 0.12, cy - h * 0.3, cx + w * 0.12, cy - h * 0.1, cx + w * 0.22, cy - h * 0.15);
        path.cubicTo(cx + w * 0.4, cy, cx + w * 0.35, cy + h * 0.38, cx, cy + h * 0.38);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'airplane':
        final path = Path();
        // Fuselage
        path.moveTo(cx, cy - h * 0.45);
        path.lineTo(cx - w * 0.08, cy + h * 0.3);
        path.lineTo(cx + w * 0.08, cy + h * 0.3);
        path.close();
        // Wings
        path.moveTo(cx - w * 0.08, cy - h * 0.05);
        path.lineTo(cx - w * 0.45, cy + h * 0.08);
        path.lineTo(cx - w * 0.08, cy + h * 0.12);
        path.moveTo(cx + w * 0.08, cy - h * 0.05);
        path.lineTo(cx + w * 0.45, cy + h * 0.08);
        path.lineTo(cx + w * 0.08, cy + h * 0.12);
        // Tail wings
        path.moveTo(cx, cy + h * 0.22);
        path.lineTo(cx - w * 0.2, cy + h * 0.3);
        path.lineTo(cx, cy + h * 0.3);
        path.lineTo(cx + w * 0.2, cy + h * 0.3);
        canvas.drawPath(path, paint);
        break;

      case 'camera':
        final path = Path();
        // Body
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.38, cy - h * 0.22, w * 0.76, h * 0.52),
          const Radius.circular(3),
        ));
        // Lens
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.18, paint);
        // Flash top bit
        path.moveTo(cx - w * 0.16, cy - h * 0.22);
        path.lineTo(cx - w * 0.12, cy - h * 0.34);
        path.lineTo(cx + w * 0.12, cy - h * 0.34);
        path.lineTo(cx + w * 0.16, cy - h * 0.22);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant HandDrawnEmojiPainter oldDelegate) {
    return oldDelegate.emojiType != emojiType || oldDelegate.color != color;
  }
}

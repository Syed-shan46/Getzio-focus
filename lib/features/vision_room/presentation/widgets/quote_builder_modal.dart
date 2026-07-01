import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuoteBuilderModal extends StatefulWidget {
  final Function(Map<String, dynamic> metadata) onSubmit;

  const QuoteBuilderModal({super.key, required this.onSubmit});

  static void show(BuildContext context, {required Function(Map<String, dynamic> metadata) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuoteBuilderModal(onSubmit: onSubmit),
    );
  }

  @override
  State<QuoteBuilderModal> createState() => _QuoteBuilderModalState();
}

class _QuoteBuilderModalState extends State<QuoteBuilderModal> {
  final _quoteController = TextEditingController();
  final _authorController = TextEditingController();
  String _selectedStyle = 'Elegant Minimal';

  final List<String> _quoteStyles = [
    'Elegant Minimal',
    'Glass Card',
    'Dark Luxury',
    'Neon',
    'Typewriter',
  ];

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  bool _addToShelf = false;

  void _submit() {
    if (_quoteController.text.trim().isEmpty) return;

    widget.onSubmit({
      'quote': _quoteController.text.trim(),
      'author': _authorController.text.trim().isEmpty ? 'Unknown' : _authorController.text.trim(),
      'style': _selectedStyle,
      'isOnShelf': _addToShelf,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Adjust for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Quote',
                style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Quote Field
              TextField(
                controller: _quoteController,
                maxLines: 4,
                style: AppTypography.titleMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter inspiring quote...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Author Field
              TextField(
                controller: _authorController,
                style: AppTypography.bodyMedium(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Author name (Optional)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.person_rounded, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Style Picker
              Text('Card Style', style: AppTypography.caption(color: Colors.white54)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quoteStyles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final style = _quoteStyles[index];
                    final isSelected = style == _selectedStyle;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStyle = style),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentBlue : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accentBlue : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          style,
                          style: AppTypography.bodyMedium(color: isSelected ? Colors.white : Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Add to Shelf Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.archive_outlined, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Wooden Shelf',
                        style: AppTypography.titleMedium(color: Colors.white70).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                  Switch(
                    value: _addToShelf,
                    activeColor: AppColors.accentBlue,
                    onChanged: (val) => setState(() => _addToShelf = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Add Quote to Board', style: AppTypography.titleMedium(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

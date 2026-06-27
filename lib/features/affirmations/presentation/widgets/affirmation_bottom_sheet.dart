import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/affirmation_model.dart';
import '../providers/affirmations_provider.dart';

class AffirmationBottomSheet extends ConsumerStatefulWidget {
  const AffirmationBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AffirmationBottomSheet(),
    );
  }

  @override
  ConsumerState<AffirmationBottomSheet> createState() => _AffirmationBottomSheetState();
}

class _AffirmationBottomSheetState extends ConsumerState<AffirmationBottomSheet> {
  // Input states
  String _title = '';
  String _text = '';
  String _author = '';
  String _category = 'Mindset';
  String _colorTheme = 'Minimal White';
  String? _emoji;

  late TextEditingController _textController;
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _emojiController;

  static const List<String> _themes = [
    'Minimal White',
    'Dark Glass',
    'Ocean Blue',
    'Sunrise Orange',
    'Forest Green',
    'Lavender',
    'Coffee Brown',
    'Midnight Black'
  ];

  static const List<String> _categories = [
    'Mindset',
    'Confidence',
    'Gratitude',
    'Discipline',
    'Business',
    'Fitness',
    'Health',
    'Success',
    'Relationships',
    'Faith',
    'Learning',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()..addListener(() {
      setState(() {
        _text = _textController.text;
      });
    });
    _titleController = TextEditingController()..addListener(() {
      setState(() {
        _title = _titleController.text;
      });
    });
    _authorController = TextEditingController()..addListener(() {
      setState(() {
        _author = _authorController.text;
      });
    });
    _emojiController = TextEditingController()..addListener(() {
      setState(() {
        _emoji = _emojiController.text;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Widget _buildPreviewCard() {
    Color cardBg = Colors.white;
    Color textCol = Colors.black;
    Color borderCol = Colors.transparent;

    switch (_colorTheme) {
      case 'Minimal White':
        cardBg = Colors.white.withOpacity(0.95);
        textCol = const Color(0xFF1F2937);
        borderCol = Colors.black12;
        break;
      case 'Dark Glass':
        cardBg = const Color(0xFF1F2937).withOpacity(0.75);
        textCol = Colors.white;
        borderCol = Colors.white10;
        break;
      case 'Midnight Black':
        cardBg = const Color(0xFF030712);
        textCol = const Color(0xFFF9FAFB);
        borderCol = Colors.white10;
        break;
      case 'Sunrise Orange':
        cardBg = const Color(0xFFFFF7ED);
        textCol = const Color(0xFF7C2D12);
        borderCol = const Color(0xFFFFEDD5);
        break;
      case 'Ocean Blue':
        cardBg = const Color(0xFFF0F9FF);
        textCol = const Color(0xFF0C4A6E);
        borderCol = const Color(0xFFE0F2FE);
        break;
      case 'Forest Green':
        cardBg = const Color(0xFFF0FDF4);
        textCol = const Color(0xFF14532D);
        borderCol = const Color(0xFFDCFCE7);
        break;
      case 'Lavender':
        cardBg = const Color(0xFFFAF5FF);
        textCol = const Color(0xFF581C87);
        borderCol = const Color(0xFFF3E8FF);
        break;
      case 'Coffee Brown':
        cardBg = const Color(0xFFFDF8F5);
        textCol = const Color(0xFF431407);
        borderCol = const Color(0xFFF5EBE6);
        break;
    }

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: textCol.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: textCol.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (_emoji != null && _emoji!.isNotEmpty)
                Text(_emoji!, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Spacer(),
          Text(
            _text.isEmpty ? '"Type affirmation text..."' : '"$_text"',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              color: textCol,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            _author.isEmpty ? '— Author' : '— $_author',
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: textCol.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull indicator & title
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Create Affirmation Art',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Live Preview updating instantly
              _buildPreviewCard(),
              const SizedBox(height: 20),

              // Title input
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Morning Intentions',
              ),
              const SizedBox(height: 12),

              // Affirmation text input
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Affirmation Text',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${_text.length} / 120',
                        style: GoogleFonts.outfit(
                          color: _text.length > 120 ? Colors.redAccent : Colors.white30,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _textController,
                    maxLines: 2,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type custom affirmation mantra...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Author & Emoji row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _authorController,
                      label: 'Author',
                      hint: 'e.g., Marcus Aurelius',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _emojiController,
                      label: 'Emoji Icon',
                      hint: 'e.g., 🙏',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories Selector
              Text(
                'Category',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _category == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _category = cat);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color Theme Selector
              Text(
                'Theme Color',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _themes.length,
                  itemBuilder: (context, idx) {
                    final theme = _themes[idx];
                    final isSelected = _colorTheme == theme;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _colorTheme = theme);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            theme,
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Create button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _text.trim().isEmpty
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          final newAff = DailyAffirmation(
                            id: const Uuid().v4(),
                            title: _title.trim().isEmpty ? 'Affirmation' : _title.trim(),
                            text: _text.trim(),
                            author: _author.trim().isEmpty ? null : _author.trim(),
                            category: _category,
                            colorTheme: _colorTheme,
                            backgroundStyle: _colorTheme,
                            emoji: _emoji?.trim().isEmpty ?? true ? null : _emoji!.trim(),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          ref.read(affirmationsProvider.notifier).addAffirmation(newAff);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Save to Workspace',
                    style: GoogleFonts.outfit(
                      color: _text.trim().isEmpty ? Colors.white24 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }
}

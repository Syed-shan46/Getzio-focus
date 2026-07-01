import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/affirmation_model.dart';
import '../providers/affirmations_provider.dart';

class DedicatedEditorScreen extends ConsumerStatefulWidget {
  final DailyAffirmation affirmation;
  const DedicatedEditorScreen({super.key, required this.affirmation});

  @override
  ConsumerState<DedicatedEditorScreen> createState() => _DedicatedEditorScreenState();
}

class _DedicatedEditorScreenState extends ConsumerState<DedicatedEditorScreen> {
  // State variables for edits
  late String _title;
  late String _text;
  late String _author;
  late String _category;
  late String _colorTheme;
  String? _emoji;

  // Text Controllers
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late TextEditingController _authorController;
  late TextEditingController _emojiController;

  // Auto-save logic
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Undo/Redo stacks
  final List<DailyAffirmation> _undoStack = [];
  final List<DailyAffirmation> _redoStack = [];

  // Theme colors configurations mapping
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
    _initFromAffirmation(widget.affirmation);

    _titleController = TextEditingController(text: _title)..addListener(_onFieldsChanged);
    _textController = TextEditingController(text: _text)..addListener(_onFieldsChanged);
    _authorController = TextEditingController(text: _author)..addListener(_onFieldsChanged);
    _emojiController = TextEditingController(text: _emoji ?? '')..addListener(_onFieldsChanged);
  }

  void _onStateModified() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted && _hasUnsavedChanges && !_isSaving) {
        _triggerAutoSave();
      }
    });
  }

  void _initFromAffirmation(DailyAffirmation aff) {
    _title = aff.title;
    _text = aff.text;
    _author = aff.author ?? '';
    _category = aff.category;
    _colorTheme = aff.colorTheme;
    _emoji = aff.emoji;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _textController.dispose();
    _authorController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  DailyAffirmation _getCurrentStateAsModel() {
    return DailyAffirmation(
      id: widget.affirmation.id,
      title: _title,
      text: _text,
      author: _author.isEmpty ? null : _author,
      category: _category,
      colorTheme: _colorTheme,
      isPinned: widget.affirmation.isPinned,
      isFavorite: widget.affirmation.isFavorite,
      emoji: _emoji?.isEmpty ?? true ? null : _emoji,
      createdAt: widget.affirmation.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Push current snapshot to undo stack
  void _pushToUndoStack() {
    _undoStack.add(_getCurrentStateAsModel());
    _redoStack.clear(); // Clear redo when a manual action occurs
  }

  void _onFieldsChanged() {
    final curText = _textController.text;
    final curTitle = _titleController.text;
    final curAuthor = _authorController.text;
    final curEmoji = _emojiController.text;

    if (curText != _text || curTitle != _title || curAuthor != _author || curEmoji != _emoji) {
      setState(() {
        _text = curText;
        _title = curTitle;
        _author = curAuthor;
        _emoji = curEmoji;
      });
      _onStateModified();
    }
  }

  void _triggerAutoSave() async {
    setState(() => _isSaving = true);
    final model = _getCurrentStateAsModel();
    await ref.read(affirmationsProvider.notifier).updateAffirmation(model);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    
    // Save current to redo stack
    _redoStack.add(_getCurrentStateAsModel());
    
    // Pop last from undo
    final prev = _undoStack.removeLast();
    _applyStateFromModel(prev);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    
    // Save current to undo stack
    _undoStack.add(_getCurrentStateAsModel());
    
    // Pop last from redo
    final next = _redoStack.removeLast();
    _applyStateFromModel(next);
  }

  void _applyStateFromModel(DailyAffirmation aff) {
    setState(() {
      _initFromAffirmation(aff);
      
      // Update text controllers without triggering listeners recursion
      _titleController.removeListener(_onFieldsChanged);
      _textController.removeListener(_onFieldsChanged);
      _authorController.removeListener(_onFieldsChanged);
      _emojiController.removeListener(_onFieldsChanged);

      _titleController.text = _title;
      _textController.text = _text;
      _authorController.text = _author;
      _emojiController.text = _emoji ?? '';

      _titleController.addListener(_onFieldsChanged);
      _textController.addListener(_onFieldsChanged);
      _authorController.addListener(_onFieldsChanged);
      _emojiController.addListener(_onFieldsChanged);
    });
    _onStateModified();
  }

  // Visual card builder for top live preview
  Widget _buildLivePreviewCard() {
    final double scW = MediaQuery.of(context).size.width;
    
    // Card styles based on selected theme
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

    final TextAlign align = TextAlign.center;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            _text.isEmpty ? '"Type your affirmation text..."' : '"$_text"',
            textAlign: align,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15.0,
              color: textCol,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            _author.isEmpty ? '— Author' : '— $_author',
            style: GoogleFonts.outfit(
              fontSize: 10,
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
          onPressed: () {
            if (_hasUnsavedChanges) {
              _triggerAutoSave();
            }
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Affirmation Editor',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              _isSaving 
                  ? 'Saving changes...' 
                  : _hasUnsavedChanges 
                      ? 'Unsaved changes' 
                      : 'All changes saved',
              style: GoogleFonts.outfit(
                color: _isSaving
                    ? Colors.amberAccent
                    : _hasUnsavedChanges
                        ? Colors.amber.withOpacity(0.7)
                        : Colors.greenAccent,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Undo
          IconButton(
            icon: Icon(Icons.undo_rounded, color: _undoStack.isNotEmpty ? Colors.white : Colors.white24, size: 20),
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          // Redo
          IconButton(
            icon: Icon(Icons.redo_rounded, color: _redoStack.isNotEmpty ? Colors.white : Colors.white24, size: 20),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Instantly updating Live Preview panel
          Container(
            color: const Color(0xFF131722),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: _buildLivePreviewCard(),
          ),

          // 2. Form edit options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title Input
                _buildSectionHeader('METADATA'),
                _buildTextInputField(
                  controller: _titleController,
                  label: 'Card Title',
                  hint: 'e.g., Growth Mindset',
                ),
                const SizedBox(height: 12),

                // Text Input
                _buildTextInputField(
                  controller: _textController,
                  label: 'Affirmation Text',
                  hint: 'Type your daily mantra...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Author Input
                _buildTextInputField(
                  controller: _authorController,
                  label: 'Author',
                  hint: 'e.g., Marcus Aurelius (or leave empty)',
                ),
                const SizedBox(height: 20),

                // Category chips
                _buildSectionHeader('CATEGORY'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _category == cat;
                    return GestureDetector(
                      onTap: () {
                        _pushToUndoStack();
                        HapticFeedback.selectionClick();
                        setState(() {
                          _category = cat;
                        });
                        _onStateModified();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Theme color selection
                _buildSectionHeader('THEME COLOR'),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _themes.length,
                    itemBuilder: (context, idx) {
                      final theme = _themes[idx];
                      final isSelected = _colorTheme == theme;
                      return GestureDetector(
                        onTap: () {
                          _pushToUndoStack();
                          HapticFeedback.selectionClick();
                          setState(() {
                            _colorTheme = theme;
                          });
                          _onStateModified();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              theme,
                              style: GoogleFonts.outfit(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Advanced controls (typography, emoji, alignment, size)
                _buildSectionHeader('VISUAL CUSTOMIZATION'),
                
                // Emoji & Alignments Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextInputField(
                        controller: _emojiController,
                        label: 'Emoji Icon',
                        hint: 'e.g., 🌱',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Save button bottom
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _triggerAutoSave();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save & Close',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          maxLines: maxLines,
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

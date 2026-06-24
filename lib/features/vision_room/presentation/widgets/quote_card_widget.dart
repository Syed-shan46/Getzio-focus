import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_item.dart';

class QuoteCardWidget extends StatelessWidget {
  final VisionItem item;

  const QuoteCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final style = metadata['style'] as String? ?? 'Elegant Minimal';
    final quote = item.content;
    final author = item.secondaryContent ?? 'Unknown';

    Widget cardContent;
    switch (style) {
      case 'Glass Card':
        cardContent = _buildGlassCard(quote, author);
        break;
      case 'Dark Luxury':
        cardContent = _buildDarkLuxury(quote, author);
        break;
      case 'Neon':
        cardContent = _buildNeon(quote, author);
        break;
      case 'Typewriter':
        cardContent = _buildTypewriter(quote, author);
        break;
      case 'Elegant Minimal':
      default:
        cardContent = _buildElegantMinimal(quote, author);
        break;
    }

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 280,
        height: 160,
        child: cardContent,
      ),
    );
  }

  Widget _buildElegantMinimal(String quote, String author) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_quote_rounded, color: Colors.black.withValues(alpha: 0.1), size: 40),
          const SizedBox(height: 8),
          Text(
            '"$quote"',
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium(color: Colors.black87).copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "— $author",
            style: AppTypography.bodyMedium(color: Colors.black54).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkLuxury(String quote, String author) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Gold border
        boxShadow: [
          BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 30)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quote.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(color: const Color(0xFFD4AF37)).copyWith(
              letterSpacing: 2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(width: 40, height: 1, color: const Color(0xFFD4AF37)),
          const SizedBox(height: 12),
          Text(
            author.toUpperCase(),
            style: AppTypography.caption(color: Colors.white70).copyWith(letterSpacing: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildNeon(String quote, String author) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.5), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.pinkAccent, blurRadius: 40, spreadRadius: -10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quote,
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium(color: Colors.white).copyWith(
              shadows: [
                const Shadow(color: Colors.pinkAccent, blurRadius: 20),
                const Shadow(color: Colors.purpleAccent, blurRadius: 40),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            author,
            style: AppTypography.bodyMedium(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTypewriter(String quote, String author) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1EA), // Vintage paper
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(2, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quote,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 18,
              color: Colors.black87,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "- $author",
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(String quote, String author) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '"$quote"',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge(color: Colors.white).copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                "— $author",
                style: AppTypography.bodyMedium(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

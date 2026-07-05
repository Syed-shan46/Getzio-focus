import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

replacement = """
    final isActive = _currentIndex == index;
    final isAffirmations = _currentIndex == 1;
    final isRoom = _currentIndex == 2;

    // Adaptive colors
    final activeColor = isAffirmations 
        ? const Color(0xFF6B4E3D) 
        : isRoom 
            ? Colors.white 
            : const Color(0xFFF97316);
            
    final inactiveColor = isAffirmations 
        ? const Color(0xFF8B7355).withValues(alpha: 0.6) 
        : isRoom 
            ? Colors.white.withValues(alpha: 0.6)
            : context.colors.textPrimary.withValues(alpha: 0.35);
"""
content = re.sub(
    r"    final isActive = _currentIndex == index;\n    final isAffirmations = _currentIndex == 1;\n\n    // Adaptive colors\n    final activeColor = isAffirmations \? const Color\(0xFF6B4E3D\) : const Color\(0xFFF97316\);\n    final inactiveColor = isAffirmations \? const Color\(0xFF8B7355\)\.withValues\(alpha: 0\.6\) : context\.colors\.textPrimary\.withValues\(alpha: 0\.35\);",
    replacement,
    content,
    flags=re.MULTILINE
)

gradient_replacement = """                  colors: isAffirmations
                      ? [
                          const Color(0xFF8B5A2B).withValues(alpha: 0.08),
                          const Color(0xFF6B4E3D).withValues(alpha: 0.08),
                        ]
                      : isRoom
                          ? [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ]
                          : [
                              const Color(0xFFF97316).withValues(alpha: 0.18),
                              const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                            ],"""
                            
content = re.sub(
    r"                  colors: isAffirmations\n                      \? \[\n                          const Color\(0xFF8B5A2B\)\.withValues\(alpha: 0\.08\),\n                          const Color\(0xFF6B4E3D\)\.withValues\(alpha: 0\.08\),\n                        \]\n                      : \[\n                          const Color\(0xFFF97316\)\.withValues\(alpha: 0\.18\),\n                          const Color\(0xFF8B5CF6\)\.withValues\(alpha: 0\.18\),\n                        \],",
    gradient_replacement,
    content,
    flags=re.MULTILINE
)

with open(filepath, 'w') as f:
    f.write(content)

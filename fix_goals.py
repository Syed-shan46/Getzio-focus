import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

start_idx = content.find("class _GoalsTab")
if start_idx != -1:
    before = content[:start_idx]
    after = content[start_idx:]
    
    replacements = [
        (r'const Color\(0xFF1D1B4E\)', 'context.colors.accentBlue.withValues(alpha: 0.15)'),
        (r'const Color\(0xFF0F121D\)', 'context.colors.bg2'),
        (r'const Color\(0xFF6366F1\)\.withOpacity\(0\.5\)', 'context.colors.accentBlue.withValues(alpha: 0.5)'),
        (r'const Color\(0xFF1E293B\)\.withOpacity\(0\.5\)', 'context.colors.glassBorder'),
        (r'const Color\(0xFF6366F1\)', 'context.colors.accentBlue'),
        (r'const Color\(0xFF0B0E17\)', 'context.colors.bg2'),
        (r'Color\(0xFF0F1524\)', 'context.colors.bg1'),
        (r'const Color\(0xFF2E2B88\)', 'context.colors.accentBlue.withValues(alpha: 0.3)'),
        # Text colors that might have been missed
        (r'Colors\.black\b', 'context.colors.darkOverlay'),
    ]

    for old, new in replacements:
        after = re.sub(old, new, after)

    # I'll also check for Colors.white inside the whole _GoalsTab since my previous script might have missed some
    after = re.sub(r'\bColors\.white\b', 'context.colors.textPrimary', after)
    after = re.sub(r'\bColors\.white70\b', 'context.colors.textSecondary', after)
    after = re.sub(r'\bColors\.white60\b', 'context.colors.textSecondary', after)
    after = re.sub(r'\bColors\.white54\b', 'context.colors.textMuted', after)

    content = before + after

with open(filepath, 'w') as f:
    f.write(content)

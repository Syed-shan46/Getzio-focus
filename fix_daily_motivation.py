import re

filepath = "lib/features/daily_motivation/presentation/screens/daily_motivation_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

replacements = [
    (r'Colors\.white\.withOpacity\(0\.7\)', 'context.colors.textSecondary'),
    (r'Colors\.white\.withOpacity\(0\.3\)', 'context.colors.textMuted.withValues(alpha: 0.3)'),
    (r'Colors\.white\.withOpacity\(0\.5\)', 'context.colors.textMuted'),
    (r'const Color\(0xFFFFD59E\)\.withOpacity\(0\.85\)', 'context.colors.textSecondary'),
    (r'const Color\(0xFFFFFFFF\)\.withValues\(alpha: p\.opacity\)', 'context.colors.textPrimary.withValues(alpha: p.opacity)')
]

for old, new in replacements:
    content = re.sub(old, new, content)

with open(filepath, 'w') as f:
    f.write(content)

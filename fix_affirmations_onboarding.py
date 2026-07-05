import re

filepath = "lib/features/onboarding/presentation/screens/affirmations_screen.dart"

with open(filepath, 'r') as f:
    content = f.read()

replacements = [
    (r'Colors\.black\.withValues\(alpha:\s*0\.2\)', r'context.colors.glass'),
    (r'Colors\.white\.withValues\(alpha:\s*0\.06\)', r'context.colors.glassBorder'),
    (r'Colors\.white\.withValues\(alpha:\s*0\.1\)', r'context.colors.glassBorder'),
    (r'Colors\.white\.withValues\(alpha:\s*0\.08\)', r'context.colors.glassBorder'),
    (r'Colors\.white24', r'context.colors.textPrimary.withValues(alpha: 0.24)'),
    (r'Colors\.white70', r'context.colors.textSecondary'),
    (r'Colors\.white', r'context.colors.textPrimary'),
    (r'const\s+TextStyle', r'TextStyle'),
    (r'const\s+InputDecoration', r'InputDecoration'),
    (r'const\s+Text', r'Text'),
    (r'const\s+Icon', r'Icon'),
]

for pat, repl in replacements:
    content = re.sub(pat, repl, content)

with open(filepath, 'w') as f:
    f.write(content)

print("Updated affirmations_screen.dart")

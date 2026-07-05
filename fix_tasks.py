import re

filepath = "lib/features/tasks/presentation/screens/tasks_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace hardcoded colors with context.colors
replacements = [
    (r'\bColor\(0xFF070A13\)', 'context.colors.bg1'),
    (r'\bColor\(0xFF1E1E2A\)', 'context.colors.bg2'),
    (r'\bColors\.white\b', 'context.colors.textPrimary'),
    (r'\bColors\.white70\b', 'context.colors.textSecondary'),
    (r'\bColors\.white54\b', 'context.colors.textMuted'),
    (r'\bColors\.white30\b', 'context.colors.textMuted.withValues(alpha: 0.5)'),
    (r'\bColors\.white24\b', 'context.colors.textMuted.withValues(alpha: 0.4)'),
    (r'\bColors\.black\.withValues', 'context.colors.darkOverlay.withValues'),
]

for old, new in replacements:
    content = re.sub(old, new, content)

# Remove const from specific widgets that might now contain dynamic colors
for widget in ['Text', 'Icon', 'TextStyle', 'BoxDecoration', 'Padding', 'SizedBox', 'Center', 'Row', 'Column', 'Container', 'Expanded', 'Align', 'FractionallySizedBox', 'CircularProgressIndicator', 'LinearProgressIndicator', 'AlwaysStoppedAnimation', 'BorderSide', 'GoogleFonts.outfit', 'Border', 'BoxShadow', 'BorderRadius', 'EdgeInsets', 'IconThemeData', 'TextSpan', 'RichText']:
    content = re.sub(r'\bconst\s+' + widget + r'\b', widget, content)

# Add import if not exists
if 'app_theme.dart' not in content:
    content = content.replace("import 'package:google_fonts/google_fonts.dart';", "import 'package:google_fonts/google_fonts.dart';\nimport '../../../../core/theme/app_theme.dart';")

with open(filepath, 'w') as f:
    f.write(content)

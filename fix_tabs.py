import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Add BuildContext context to helper methods in _GoalsTabState and _ProfileTab
methods = [
    r"_buildFilterTab",
    r"_buildGoalCard",
    r"_buildProfileStatRow",
    r"_buildProfileStatCard"
]

for method in methods:
    # Update method definition: Widget _buildFilterTab(String label, ...) -> Widget _buildFilterTab(BuildContext context, String label, ...)
    content = re.sub(rf"Widget ({method})\((.*?)\)\s*{{", r"Widget \1(BuildContext context, \2) {", content)
    # Fix if it already has context or empty args
    content = content.replace("BuildContext context, BuildContext context", "BuildContext context")
    content = content.replace("BuildContext context, )", "BuildContext context)")

    # Update method calls
    content = re.sub(rf"({method})\((.*?)\)", r"\1(context, \2)", content)
    # Fix if we duplicated context or passed it twice
    content = content.replace(f"(context, context,", f"(context,")

# Now, we should only replace Colors within the range of _GoalsTab and _ProfileTab
# Find start index of _GoalsTab
start_idx = content.find("class _GoalsTab")
if start_idx != -1:
    before = content[:start_idx]
    after = content[start_idx:]
    
    replacements = [
        (r'\bColor\(0xFF070A13\)', 'context.colors.bg1'),
        (r'\bColor\(0xFF1E1E2A\)', 'context.colors.bg2'),
        (r'\bColors\.white\b', 'context.colors.textPrimary'),
        (r'\bColors\.white70\b', 'context.colors.textSecondary'),
        (r'\bColors\.white60\b', 'context.colors.textSecondary'),
        (r'\bColors\.white54\b', 'context.colors.textMuted'),
        (r'\bColors\.white30\b', 'context.colors.textMuted.withValues(alpha: 0.5)'),
        (r'\bColors\.white24\b', 'context.colors.textMuted.withValues(alpha: 0.4)'),
        (r'\bColors\.white12\b', 'context.colors.glassBorder'),
        (r'\bColors\.white10\b', 'context.colors.glassBorder'),
        (r'\bColors\.black\.withValues', 'context.colors.darkOverlay.withValues'),
    ]

    for old, new in replacements:
        after = re.sub(old, new, after)

    # Remove const before Widgets in the modified section
    for widget in ['Text', 'Icon', 'TextStyle', 'BoxDecoration', 'Padding', 'SizedBox', 'Center', 'Row', 'Column', 'Container', 'Expanded', 'Align', 'FractionallySizedBox', 'CircularProgressIndicator', 'LinearProgressIndicator', 'AlwaysStoppedAnimation', 'BorderSide', 'GoogleFonts.outfit', 'Border', 'BoxShadow', 'BorderRadius', 'EdgeInsets', 'IconThemeData', 'TextSpan', 'RichText']:
        after = re.sub(r'\bconst\s+' + widget + r'\b', widget, after)

    content = before + after

with open(filepath, 'w') as f:
    f.write(content)

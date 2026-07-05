import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

start_idx = content.find("class _ProfileTab")
end_idx = content.find("class _GoalsTab")

if start_idx != -1 and end_idx != -1:
    before = content[:start_idx]
    middle = content[start_idx:end_idx]
    after = content[end_idx:]
    
    # 1. Background colors
    middle = re.sub(r'Color\(0xFF0F1524\)', 'context.colors.bg1', middle)
    middle = re.sub(r'Color\(0xFF070A13\)', 'context.colors.bg2', middle)

    # 2. Text/Icon primary colors
    middle = re.sub(r'\bColors\.white\b', 'context.colors.textPrimary', middle)
    
    # 3. Muted/Secondary Text and Icon colors
    middle = re.sub(r'\bColors\.white70\b', 'context.colors.textSecondary', middle)
    middle = re.sub(r'\bColors\.white60\b', 'context.colors.textSecondary', middle)
    middle = re.sub(r'\bColors\.white54\b', 'context.colors.textMuted', middle)
    middle = re.sub(r'\bColors\.white30\b', 'context.colors.textMuted', middle)
    
    # Wait, some places check for Colors.white to conditionally color something.
    # The output had: color: achieved ? color : Colors.white.withValues(alpha: 0.1) -> this will become context.colors.textPrimary.withValues(alpha: 0.1). That works beautifully.
    
    # We should handle color: color == Colors.redAccent ? Colors.redAccent : Colors.white70
    # Wait, if we blindly replace Colors.white70 here it's fine.

    content = before + middle + after

with open(filepath, 'w') as f:
    f.write(content)

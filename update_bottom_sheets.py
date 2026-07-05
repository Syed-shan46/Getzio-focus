import os
import re

files_to_update = [
    "lib/features/os_dashboard/presentation/widgets/setup_assistant_sheet.dart",
    "lib/features/os_dashboard/presentation/widgets/workspace_customization.dart",
    "lib/features/os_dashboard/presentation/widgets/todays_checklist.dart",
    "lib/features/affirmations/presentation/widgets/daily_spark_sheet.dart",
    "lib/features/affirmations/presentation/widgets/affirmation_bottom_sheet.dart",
    "lib/features/tasks/presentation/screens/tasks_screen.dart",
    "lib/features/vision_room/presentation/widgets/smart_object_sheets.dart"
]

def process_file(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return

    with open(filepath, 'r') as f:
        content = f.read()

    # Make sure app_theme is imported for context.colors
    if 'import \'package:getzio_todo_app/core/theme/app_theme.dart\';' not in content and 'app_theme.dart' not in content:
        # insert it after the last import
        import_stmt = "import 'package:getzio_todo_app/core/theme/app_theme.dart';\n"
        last_import = content.rfind('import ')
        if last_import != -1:
            end_of_line = content.find('\n', last_import)
            content = content[:end_of_line+1] + import_stmt + content[end_of_line+1:]

    # Replace hardcoded dark backgrounds
    content = re.sub(r'const Color\(0xFF070A13\)', r'context.colors.bg1', content)
    content = re.sub(r'const Color\(0xFF09090B\)', r'context.colors.bg1', content)
    content = re.sub(r'const Color\(0xFF18181B\)', r'context.colors.bg2', content)
    content = re.sub(r'const Color\(0xFF1E293B\)', r'context.colors.surface', content)
    content = re.sub(r'Color\(0xFF070A13\)', r'context.colors.bg1', content)
    content = re.sub(r'Color\(0xFF09090B\)', r'context.colors.bg1', content)
    content = re.sub(r'Color\(0xFF18181B\)', r'context.colors.bg2', content)
    content = re.sub(r'Color\(0xFF1E293B\)', r'context.colors.surface', content)

    # Replace Colors.white borders
    content = re.sub(r'Colors\.white\.withValues\(alpha: 0\.08\)', r'context.colors.border', content)
    content = re.sub(r'Colors\.white\.withValues\(alpha: 0\.1\)', r'context.colors.border', content)
    
    # Text colors
    content = re.sub(r'color: Colors\.white70', r'color: context.colors.textSecondary', content)
    content = re.sub(r'color: Colors\.white60', r'color: context.colors.textSecondary', content)
    content = re.sub(r'color: Colors\.white54', r'color: context.colors.textSecondary.withValues(alpha: 0.7)', content)
    content = re.sub(r'color: Colors\.white38', r'color: context.colors.textMuted', content)
    content = re.sub(r'color: Colors\.white', r'color: context.colors.textPrimary', content)

    # Remove invalid constants caused by these replacements
    # Since we replaced const Color with context.colors (not const), we need to strip const from BoxDecorations/TextStyles
    content = re.sub(r'const BoxDecoration\(', r'BoxDecoration(', content)
    content = re.sub(r'const TextStyle\(', r'TextStyle(', content)
    content = re.sub(r'const Border\(', r'Border(', content)
    content = re.sub(r'const BorderRadius', r'BorderRadius', content) # Might be safe, sometimes used dynamically
    # For BorderRadius.vertical(top: Radius.circular(32)) etc. it can be const, but removing const is safer if it contains non-const inside (though BorderRadius usually doesn't).
    
    # We also need to remove const from Text if we replaced its color in style
    # actually regexing `const Text(` -> `Text(` is usually safer overall
    content = re.sub(r'const Text\(', r'Text(', content)

    with open(filepath, 'w') as f:
        f.write(content)

for filepath in files_to_update:
    process_file(filepath)

print("Done")

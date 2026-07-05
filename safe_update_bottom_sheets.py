import os
import re
import subprocess

files_to_update = [
    "lib/features/os_dashboard/presentation/widgets/setup_assistant_sheet.dart",
    "lib/features/os_dashboard/presentation/widgets/workspace_customization.dart",
    "lib/features/os_dashboard/presentation/widgets/todays_checklist.dart",
    "lib/features/affirmations/presentation/widgets/daily_spark_sheet.dart",
    "lib/features/affirmations/presentation/widgets/affirmation_bottom_sheet.dart",
    "lib/features/tasks/presentation/screens/tasks_screen.dart",
    "lib/features/vision_room/presentation/widgets/smart_object_sheets.dart"
]

def add_import(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    if 'package:getzio_todo_app/core/theme/app_theme.dart' not in content:
        import_stmt = "import 'package:getzio_todo_app/core/theme/app_theme.dart';\n"
        last_import = content.rfind('import ')
        if last_import != -1:
            end_of_line = content.find('\n', last_import)
            content = content[:end_of_line+1] + import_stmt + content[end_of_line+1:]
        with open(filepath, 'w') as f:
            f.write(content)

def do_replacements(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    replacements = [
        (r'const Color\(0xFF070A13\)', r'context.colors.bg1'),
        (r'const Color\(0xFF09090B\)', r'context.colors.bg1'),
        (r'const Color\(0xFF18181B\)', r'context.colors.bg2'),
        (r'const Color\(0xFF1E293B\)', r'context.colors.bg2'),
        (r'Color\(0xFF070A13\)', r'context.colors.bg1'),
        (r'Color\(0xFF09090B\)', r'context.colors.bg1'),
        (r'Color\(0xFF18181B\)', r'context.colors.bg2'),
        (r'Color\(0xFF1E293B\)', r'context.colors.bg2'),
        (r'Colors\.white\.withValues\(alpha: 0\.08\)', r'context.colors.glassBorder'),
        (r'Colors\.white\.withValues\(alpha: 0\.1\)', r'context.colors.glassBorder'),
        (r'Colors\.white70', r'context.colors.textSecondary'),
        (r'Colors\.white60', r'context.colors.textSecondary'),
        (r'Colors\.white54', r'context.colors.textSecondary.withValues(alpha: 0.7)'),
        (r'Colors\.white38', r'context.colors.textMuted'),
        (r'Colors\.white24', r'context.colors.textPrimary.withValues(alpha: 0.24)'),
        (r'Colors\.white12', r'context.colors.textPrimary.withValues(alpha: 0.12)'),
        (r'Colors\.white10', r'context.colors.textPrimary.withValues(alpha: 0.10)'),
        (r'Colors\.white', r'context.colors.textPrimary'),
    ]

    for pat, repl in replacements:
        content = re.sub(pat, repl, content)

    with open(filepath, 'w') as f:
        f.write(content)

for filepath in files_to_update:
    add_import(filepath)
    do_replacements(filepath)

print("Initial replacements done.")

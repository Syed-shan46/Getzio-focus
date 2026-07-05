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

def fix_file(filepath):
    if not os.path.exists(filepath):
        return

    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Fix context.colors.border -> context.colors.glassBorder
    content = content.replace('context.colors.border', 'context.colors.glassBorder')
    
    # 2. Fix context.colors.surface -> context.colors.bg2
    content = content.replace('context.colors.surface', 'context.colors.bg2')

    # 3. Fix textPrimaryXX -> textPrimary.withValues(alpha: 0.XX)
    # Using regex to match textPrimary followed by 2 digits
    content = re.sub(
        r'context\.colors\.textPrimary(\d{2})',
        lambda m: f'context.colors.textPrimary.withValues(alpha: 0.{m.group(1)})',
        content
    )

    # 4. Remove lingering 'const' keywords from things that use context.colors
    # In Dart, if an ancestor is const, we might need to remove it. 
    # E.g. const Padding(... context.colors ...) -> Padding(
    # We will use regex to find const <Widget> ... context.colors
    # It's hard to do a full AST parser in regex, but we can catch obvious ones.
    
    # Let's catch `const Center(` or `const SizedBox(` or `const Row(` or `const Column(` 
    # if it has a child with context.colors somewhere inside.
    # We'll just run a general pass to strip `const ` before `Widget` names if they contain `context.colors` on the same line or closely,
    # actually it's easier to just let dart analyzer tell us which ones are invalid_constant and we fix them manually or write a script to parse the output.
    
    # For now, let's fix known invalid constants in smart_object_sheets and workspace_customization
    # e.g., const Divider(color: context.colors.glassBorder) -> Divider(color: context.colors.glassBorder)
    content = content.replace('const Divider(color: context.colors.glassBorder)', 'Divider(color: context.colors.glassBorder)')
    content = content.replace('const Icon(', 'Icon(') # Strip const from all Icons, usually safe
    content = content.replace('const Text(', 'Text(') # Strip const from all Texts
    content = content.replace('const Padding(', 'Padding(') # Strip const from all Paddings
    content = content.replace('const SizedBox(', 'SizedBox(') # Strip const from all SizedBoxes
    content = content.replace('const Edge', 'Edge') # Strip const EdgeInsets
    content = content.replace('const BorderRadius', 'BorderRadius') # Strip const BorderRadius
    content = content.replace('const Box', 'Box') # Strip const BoxConstraints/BoxDecoration

    # Fix const_eval_method_invocation errors
    # E.g. const Color(0xFFC9A96E).withValues(...) is not a constant if withValues is used
    # Or context.colors.textPrimary.withValues(...)
    content = re.sub(r'const\s+Color\([^)]+\)\.withValues', r'Color\([^)]+\)\.withValues', content)

    # Add missing context definition
    # workspace_customization.dart:454:16 Undefined name 'context'
    # Wait, workspace_customization line 454 undefined 'context'. I'll look into it separately.

    with open(filepath, 'w') as f:
        f.write(content)

for filepath in files_to_update:
    fix_file(filepath)

print("Fixed syntax issues")

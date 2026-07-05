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

    # 1. Fix context.colors.textPrimaryXX (which I missed earlier because the regex was \d{2} but maybe it was textPrimary30 in error log)
    # Wait, my earlier script did \d{2}. Let's see, it might have failed if it was textPrimary.withValues(alpha: 0.30)? No, the error is undefined getter 'textPrimary30'.
    content = re.sub(
        r'context\.colors\.textPrimary(\d{2})',
        lambda m: f'context.colors.textPrimary.withValues(alpha: 0.{m.group(1)})',
        content
    )

    # 2. Fix todays_checklist.dart _tabs
    if 'todays_checklist.dart' in filepath:
        # Move _tabs to a getter 
        # From: static _tabs = [ ... ];
        # To: List<_CategoryTab> get _tabs => [ ... ];
        content = content.replace('static _tabs = [', 'List<_CategoryTab> get _tabs => [')
        content = content.replace('static final _tabs = [', 'List<_CategoryTab> get _tabs => [')

    # 3. Fix workspace_customization.dart context issue
    if 'workspace_customization.dart' in filepath:
        content = content.replace('Widget _buildSectionHeader(String title) {', 'Widget _buildSectionHeader(BuildContext context, String title) {')
        content = content.replace('_buildSectionHeader(', '_buildSectionHeader(context, ')
        # Because we replaced the definition, we might have accidentally replaced it twice if it's called as `_buildSectionHeader('foo')` -> `_buildSectionHeader(context, 'foo')`.
        # Just to be safe:
        content = content.replace('_buildSectionHeader(context, BuildContext context,', '_buildSectionHeader(BuildContext context,')

    # 4. Fix withOpacity -> withValues(alpha:)
    content = re.sub(
        r'\.withOpacity\(([^)]+)\)',
        r'.withValues(alpha: \1)',
        content
    )

    with open(filepath, 'w') as f:
        f.write(content)

for filepath in files_to_update:
    fix_file(filepath)

print("Fixed remaining issues")

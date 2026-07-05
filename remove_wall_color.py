import re

filepath = 'lib/features/os_dashboard/presentation/widgets/workspace_customization.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "_buildSectionHeader(context, 'Backdrop Wall Color')" in line:
        skip = True
        continue
    if skip:
        # We need to skip until the next section header or a known point
        if "_buildSectionHeader(context, 'Workspace Plant')" in line:
            skip = False
            new_lines.append(line)
        continue
    
    if "Color _getWallColorPreview(String color) {" in line:
        skip = True
        continue
    if skip and "LinearGradient _getWoodPreviewGradient(String style) {" in line:
        skip = False
        new_lines.append(line)
        continue
    
    if not skip:
        new_lines.append(line)

with open(filepath, 'w') as f:
    f.writelines(new_lines)


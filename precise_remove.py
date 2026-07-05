import re

filepath = 'lib/features/os_dashboard/presentation/widgets/workspace_customization.dart'
with open(filepath, 'r') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    # lines 110-151 (0-indexed 109 to 150)
    if 109 <= i <= 150:
        continue
    # lines 209-267 (0-indexed 208 to 266)
    if 208 <= i <= 266:
        continue
    
    # Remove wallColors variable definition
    if "final wallColors = ['Deep Indigo'" in line:
        continue
    # Remove plantTypes variable definition
    if "final plantTypes = ['Bonsai', 'Snake Plant'" in line:
        continue
        
    # Remove _getWallColorPreview function which is around line 430
    if "Color _getWallColorPreview(String color) {" in line:
        pass # we'll handle this separately by regex

    new_lines.append(line)

content = "".join(new_lines)
# Remove _getWallColorPreview function block
content = re.sub(r"Color _getWallColorPreview\(String color\) \{[\s\S]*?\}", "", content)

with open(filepath, 'w') as f:
    f.write(content)


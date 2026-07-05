import re

filepath = 'lib/features/os_dashboard/presentation/widgets/workspace_customization.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Remove 'Bonsai' from plantTypes
content = content.replace("final plantTypes = ['Bonsai', 'Snake Plant', 'Monstera', 'Peace Lily'];", "final plantTypes = ['Snake Plant', 'Monstera', 'Peace Lily'];")

# Remove wallColors completely
content = re.sub(r"final wallColors = \[.*?\];\n\s*", "", content)

# Remove the UI section for Wall Color. It starts around `_buildSectionHeader(context, 'Backdrop Wall Color'),` or similar
# Let's search for "Backdrop Wall Color"
content = re.sub(r"_buildSectionHeader\(context,\s*'Backdrop Wall Color'\),\s*const SizedBox\(height:\s*12\),\s*SizedBox\(\s*height:\s*60,\s*child:\s*ListView\.builder\(.*?scrollDirection:\s*Axis\.horizontal,.*?\),\s*\),\s*const SizedBox\(height:\s*24\),\s*", "", content, flags=re.DOTALL)
# Also need to handle without 'const' since I removed consts earlier
content = re.sub(r"_buildSectionHeader\(context,\s*'Backdrop Wall Color'\),\s*SizedBox\(height:\s*12\),\s*SizedBox\(\s*height:\s*60,\s*child:\s*ListView\.builder\([\s\S]*?scrollDirection:\s*Axis\.horizontal,[\s\S]*?\),\s*\),\s*SizedBox\(height:\s*24\),\s*", "", content)
# And the `_getWallColorPreview` function if it exists.
content = re.sub(r"Color _getWallColorPreview\(String color\) \{[\s\S]*?\}", "", content)

with open(filepath, 'w') as f:
    f.write(content)

# Update default in os_providers.dart
os_providers_path = 'lib/features/os_dashboard/presentation/providers/os_providers.dart'
with open(os_providers_path, 'r') as f:
    os_content = f.read()
# Wait, my grep showed it might already be Oak in some places? Or Walnut?
os_content = os_content.replace("'woodTexture': 'Walnut'", "'woodTexture': 'Oak'")
with open(os_providers_path, 'w') as f:
    f.write(os_content)

# sample_data_seeding_service.dart
seeding_path = 'lib/core/storage/sample_data_seeding_service.dart'
with open(seeding_path, 'r') as f:
    seed_content = f.read()
seed_content = seed_content.replace("'woodTexture': 'Walnut'", "'woodTexture': 'Oak'")
with open(seeding_path, 'w') as f:
    f.write(seed_content)

print("Updated workspace customization")

import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix parameter definitions
content = content.replace("Widget _buildProfileStatRow(context, BuildContext context,", "Widget _buildProfileStatRow(BuildContext context,")
content = content.replace("Widget _buildGoalCard(context, BuildContext context,", "Widget _buildGoalCard(BuildContext context,")

# Fix const AppColors issues across the whole file
content = re.sub(r'const TextStyle\(\s*color:\s*AppColors\.accentBlue', r'TextStyle(color: AppColors.accentBlue', content)
content = re.sub(r'const TextStyle\(\s*color:\s*AppColors\.accentEmerald', r'TextStyle(color: AppColors.accentEmerald', content)
content = re.sub(r'const Icon\(Icons\.health_and_safety_rounded,\s*color:\s*AppColors\.accentEmerald', r'Icon(Icons.health_and_safety_rounded, color: AppColors.accentEmerald', content)
content = re.sub(r'const Icon\(Icons\.favorite_rounded,\s*color:\s*AppColors\.accentBlue', r'Icon(Icons.favorite_rounded, color: AppColors.accentBlue', content)
content = re.sub(r'const AlwaysStoppedAnimation<Color>\(\s*AppColors\.accentBlue', r'AlwaysStoppedAnimation<Color>(AppColors.accentBlue', content)
content = re.sub(r'const AlwaysStoppedAnimation<Color>\(\s*AppColors\.accentEmerald', r'AlwaysStoppedAnimation<Color>(AppColors.accentEmerald', content)
content = re.sub(r'const Icon\(Icons\.monitor_heart_rounded,\s*color:\s*AppColors\.accentBlue', r'Icon(Icons.monitor_heart_rounded, color: AppColors.accentBlue', content)
content = re.sub(r'const Icon\(Icons\.health_and_safety_rounded,\s*color:\s*AppColors\.accentBlue', r'Icon(Icons.health_and_safety_rounded, color: AppColors.accentBlue', content)


with open(filepath, 'w') as f:
    f.write(content)

import re

filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix the broken signature
content = content.replace("""  Widget _buildMilestone(
                context,
    BuildContext context,
    String title,""", """  Widget _buildMilestone(
    BuildContext context,
    String title,""")

with open(filepath, 'w') as f:
    f.write(content)

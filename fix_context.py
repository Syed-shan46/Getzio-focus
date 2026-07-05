import re
import sys

def fix_tasks_screen():
    filepath = "lib/features/tasks/presentation/screens/tasks_screen.dart"
    with open(filepath, 'r') as f:
        content = f.read()

    # Pass context to helper methods in tasks_screen
    content = content.replace("Widget _buildSmallStatContainer(\n", "Widget _buildSmallStatContainer(\n    BuildContext context,\n")
    content = content.replace("_buildSmallStatContainer(", "_buildSmallStatContainer(context, ")
    
    with open(filepath, 'w') as f:
        f.write(content)

def fix_dashboard():
    filepath = "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart"
    with open(filepath, 'r') as f:
        content = f.read()

    # Pass context to helper methods in classic_dashboard_widget
    methods = [
        "_buildTrackersGrid",
        "_buildDailyQuoteCard",
        "_buildHabitsSection",
        "_buildGoalsSection",
        "_buildProfileStatRow",
        "_buildProfileStatCard"
    ]
    
    for method in methods:
        # Update method definition
        content = re.sub(rf"Widget {method}\((.*?)\) {{", rf"Widget {method}(BuildContext context, \1) {{", content)
        content = content.replace(f"BuildContext context, BuildContext context,", f"BuildContext context,")
        
        # Update method calls
        content = re.sub(rf"{method}\((.*?)\)", rf"{method}(context, \1)", content)
        content = content.replace(f"{method}(context, context,", f"{method}(context,")

    with open(filepath, 'w') as f:
        f.write(content)

fix_tasks_screen()
fix_dashboard()
print("Done")

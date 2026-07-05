import sys

errors = [
    "lib/features/auth/presentation/screens/legal_document_screen.dart:69",
    "lib/features/auth/presentation/screens/legal_document_screen.dart:97",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:436",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:441",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:454",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:457",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:726",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:732",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:769",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:780",
    "lib/features/onboarding/presentation/screens/health_screen.dart:142",
    "lib/features/onboarding/presentation/screens/health_screen.dart:154",
    "lib/features/onboarding/presentation/screens/health_screen.dart:166",
    "lib/features/onboarding/presentation/screens/health_screen.dart:178",
    "lib/features/onboarding/presentation/widgets/onboarding_bottom_bar.dart:144",
    "lib/features/onboarding/presentation/widgets/onboarding_bottom_bar.dart:146",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:522",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:559",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:565",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:758",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:782",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:832",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:850",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:1224",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:1262",
    "lib/features/os_dashboard/presentation/widgets/living_plant.dart:117",
    "lib/features/os_dashboard/presentation/widgets/personal_growth_locked.dart:159",
    "lib/features/os_dashboard/presentation/widgets/personal_growth_locked.dart:183",
    "lib/features/os_dashboard/presentation/widgets/personal_growth_locked.dart:192",
    "lib/features/os_dashboard/presentation/widgets/personal_growth_locked.dart:201",
    "lib/features/os_dashboard/presentation/widgets/personal_growth_locked.dart:207",
    "lib/features/os_dashboard/presentation/widgets/todays_checklist.dart:517",
    "lib/features/os_dashboard/presentation/widgets/todays_checklist.dart:518",
    "lib/features/todo/presentation/widgets/animated_checkbox.dart:17"
]

for err in errors:
    filepath, line_str = err.split(':')
    line_num = int(line_str) - 1 # 0-indexed
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    if 'context.colors.' in lines[line_num]:
        lines[line_num] = lines[line_num].replace('context.colors.', 'AppColors.')
    else:
        # Sometimes the error is slightly off, search nearby
        for i in range(max(0, line_num - 2), min(len(lines), line_num + 3)):
            if 'context.colors.' in lines[i]:
                lines[i] = lines[i].replace('context.colors.', 'AppColors.')
                break
                
    with open(filepath, 'w') as f:
        f.writelines(lines)

print("Done reverting context")

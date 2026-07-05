import re

errors = [
    "lib/features/auth/presentation/screens/legal_document_screen.dart:69",
    "lib/features/auth/presentation/screens/onboarding_screen.dart:203",
    "lib/features/auth/presentation/screens/otp_verification_screen.dart:174",
    "lib/features/auth/presentation/screens/phone_login_screen.dart:178",
    "lib/features/auth/presentation/screens/phone_login_screen.dart:253",
    "lib/features/auth/presentation/screens/phone_login_screen.dart:264",
    "lib/features/auth/presentation/widgets/save_workspace_sheet.dart:74",
    "lib/features/onboarding/presentation/screens/review_screen.dart:168",
    "lib/features/onboarding/presentation/screens/welcome_screen.dart:105",
    "lib/features/os_dashboard/presentation/screens/os_dashboard_screen.dart:1366",
    "lib/features/os_dashboard/presentation/screens/os_dashboard_screen.dart:1431",
    "lib/features/os_dashboard/presentation/screens/os_dashboard_screen.dart:2130",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:565",
    "lib/features/os_dashboard/presentation/widgets/classic_dashboard_widget.dart:758",
    "lib/features/os_dashboard/presentation/widgets/todays_checklist.dart:39",
    "lib/features/os_dashboard/presentation/widgets/workspace_customization.dart:429",
    "lib/features/todo/presentation/screens/home_screen.dart:225",
    "lib/features/todo/presentation/screens/home_screen.dart:408",
    "lib/features/todo/presentation/screens/home_screen.dart:536",
    "lib/features/todo/presentation/widgets/glass_fab.dart:22",
    "lib/features/vision_room/presentation/widgets/customization_sheet.dart:373",
    "lib/features/vision_room/presentation/widgets/customization_sheet.dart:646",
    "lib/features/vision_room/presentation/widgets/customization_sheet.dart:1718",
    "lib/features/vision_room/presentation/widgets/vision_creation_sheet.dart:438"
]

for err in errors:
    filepath, line_str = err.split(':')
    line_num = int(line_str) - 1 # 0-indexed
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    # Search upwards from line_num up to 10 lines
    for i in range(line_num, max(-1, line_num - 15), -1):
        if 'const ' in lines[i]:
            lines[i] = lines[i].replace('const ', '', 1)
            break
            
    with open(filepath, 'w') as f:
        f.writelines(lines)

print("Done fixing multi-line consts")

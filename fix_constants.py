import subprocess
import re
import os

def fix_errors():
    changed_files = set()
    for _ in range(5):
        print(f"Running flutter analyze (pass {_})...")
        res = subprocess.run(['flutter', 'analyze',
            'lib/features/os_dashboard/presentation/widgets/setup_assistant_sheet.dart',
            'lib/features/os_dashboard/presentation/widgets/workspace_customization.dart',
            'lib/features/os_dashboard/presentation/widgets/todays_checklist.dart',
            'lib/features/affirmations/presentation/widgets/daily_spark_sheet.dart',
            'lib/features/affirmations/presentation/widgets/affirmation_bottom_sheet.dart',
            'lib/features/tasks/presentation/screens/tasks_screen.dart',
            'lib/features/vision_room/presentation/widgets/smart_object_sheets.dart'
        ], capture_output=True, text=True)
        
        if res.returncode == 0 and 'No issues found' in res.stdout:
            print("No more errors!")
            break
            
        lines = res.stdout.split('\n')
        fixed_something = False
        
        # Group errors by file and line
        errors = {}
        for line in lines:
            if 'invalid_constant' in line or 'const_eval_method_invocation' in line:
                parts = line.split(' • ')
                if len(parts) >= 3:
                    file_line_col = parts[-2].strip()
                    file_parts = file_line_col.split(':')
                    if len(file_parts) == 3:
                        filepath = file_parts[0]
                        lineno = int(file_parts[1])
                        if filepath not in errors:
                            errors[filepath] = []
                        errors[filepath].append(lineno)
                        
        for filepath, linenos in errors.items():
            if not os.path.exists(filepath):
                continue
                
            with open(filepath, 'r') as f:
                content_lines = f.readlines()
                
            for lineno in set(linenos):
                idx = lineno - 1
                if 0 <= idx < len(content_lines):
                    old_line = content_lines[idx]
                    # Simple fix: replace 'const ' with '' on the error line
                    new_line = old_line.replace('const ', '')
                    if new_line != old_line:
                        content_lines[idx] = new_line
                        fixed_something = True
                        changed_files.add(filepath)
                    else:
                        # Sometimes the 'const' is on a previous line (e.g. const Text( \n ... )
                        # Let's search upwards up to 5 lines for a 'const ' to remove
                        for offset in range(1, 6):
                            if idx - offset >= 0:
                                check_line = content_lines[idx - offset]
                                if 'const ' in check_line:
                                    content_lines[idx - offset] = check_line.replace('const ', '')
                                    fixed_something = True
                                    changed_files.add(filepath)
                                    break
                                    
            with open(filepath, 'w') as f:
                f.writelines(content_lines)
                
        if not fixed_something:
            print("Could not automatically fix remaining errors.")
            print(res.stdout)
            break

fix_errors()
print("Done fixing constants.")

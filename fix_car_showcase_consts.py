import re

filepath = "lib/features/os_dashboard/presentation/screens/os_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Fix line 5914: const BoxDecoration( ... gradient: LinearGradient( ... colors: [context.colors.bg2, context.colors.bg1] ...
content = re.sub(
    r'decoration: const BoxDecoration\(\n                  gradient: LinearGradient\(\n                    colors: \[context\.colors\.bg2, context\.colors\.bg1\],',
    r'decoration: BoxDecoration(\n                  gradient: LinearGradient(\n                    colors: [context.colors.bg2, context.colors.bg1],',
    content
)

# 2. Fix line 5969: const BoxDecoration( color: context.colors.textMuted
content = re.sub(
    r'decoration: const BoxDecoration\(\n                  color: context\.colors\.textMuted,\n                  shape: BoxShape\.circle,\n                \),',
    r'decoration: BoxDecoration(\n                  color: context.colors.textMuted,\n                  shape: BoxShape.circle,\n                ),',
    content
)

with open(filepath, 'w') as f:
    f.write(content)

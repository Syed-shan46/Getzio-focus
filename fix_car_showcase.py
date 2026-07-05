import re

filepath = "lib/features/os_dashboard/presentation/screens/os_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update Inner recessed shadow / seal frame (line 947)
content = re.sub(
    r'// Inner recessed shadow / seal frame\n          decoration: BoxDecoration\(\n            borderRadius: BorderRadius\.circular\(8\),\n            border: Border\.all\(\n              color: Colors\.black\.withValues\(alpha: 0\.75\),',
    r'// Inner recessed shadow / seal frame\n          decoration: BoxDecoration(\n            borderRadius: BorderRadius.circular(8),\n            border: Border.all(\n              color: context.colors.textPrimary.withValues(alpha: 0.15),',
    content
)

# 2. Update GlassDisplayCase implementation (around 5838)
start_idx = content.find("class GlassDisplayCase extends StatelessWidget {")
end_idx = content.find("class SpotlightBeamPainter", start_idx)

if start_idx != -1 and end_idx != -1:
    before = content[:start_idx]
    middle = content[start_idx:end_idx]
    after = content[end_idx:]
    
    # Update Glass case container background
    middle = middle.replace("color: Colors.white.withOpacity(0.025),", "color: context.colors.textPrimary.withValues(alpha: 0.025),")
    
    # Update shadow
    middle = middle.replace("color: Colors.black.withOpacity(0.42),", "color: context.colors.textPrimary.withValues(alpha: 0.1),")
    
    # Update display stand base
    middle = middle.replace("colors: [Color(0xFF27272A), Color(0xFF09090B)],", "colors: [context.colors.bg2, context.colors.bg1],")
    middle = middle.replace("color: Colors.white10,", "color: context.colors.glassBorder,")
    
    # Update glass reflections
    middle = middle.replace("Colors.white.withOpacity(0.16)", "context.colors.textPrimary.withValues(alpha: 0.16)")
    middle = middle.replace("Colors.white.withOpacity(0.04)", "context.colors.textPrimary.withValues(alpha: 0.04)")
    middle = middle.replace("Colors.white.withOpacity(0.02)", "context.colors.textPrimary.withValues(alpha: 0.02)")
    middle = middle.replace("Colors.white.withOpacity(0.12)", "context.colors.textPrimary.withValues(alpha: 0.12)")
    
    # Update metallic screws
    middle = middle.replace("color: Color(0xFF94A3B8),", "color: context.colors.textMuted,")
    
    # Also tint border
    middle = middle.replace("border: Border.all(color: glassBorderColor, width: 0.8),", "border: Border.all(color: context.colors.glassBorder, width: 0.8),")

    content = before + middle + after

with open(filepath, 'w') as f:
    f.write(content)

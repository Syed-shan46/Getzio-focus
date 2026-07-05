def replace_in_file(filepath, old, new):
    with open(filepath, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)

replace_in_file('lib/features/os_dashboard/presentation/providers/os_providers.dart', "'woodTexture': 'Walnut'", "'woodTexture': 'Oak'")
replace_in_file('lib/core/storage/sample_data_seeding_service.dart', "'woodTexture': 'Walnut'", "'woodTexture': 'Oak'")
replace_in_file('lib/features/auth/domain/services/guest_migration_service.dart', "'woodFinish': 'Walnut'", "'woodFinish': 'Oak'")
print("Updated defaults")

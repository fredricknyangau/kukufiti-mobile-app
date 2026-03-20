import os
import shutil

base = "/home/ubuntu/Projects/kuku-fiti-project/mobile/lib"
src_dir = os.path.join(base, "presentation/screens/features")

# Exact folder names for domains
mappings = {
    "admin_dashboard_screen.dart": "admin_dashboard_management",
    "audit_logs_screen.dart": "audit_logs_management",
    "calendar_screen.dart": "calendar_management",
    "market_screen.dart": "market_management",
    "profile_screen.dart": "profile_management",
    "reports_screen.dart": "reports_management",
    "resources_screen.dart": "resources_management",
}

print("Starting migrations...")
count = 0
for filename, domain in mappings.items():
    src_file = os.path.join(src_dir, filename)
    target_dir = os.path.join(base, "features", domain, "presentation/screens")
    
    if os.path.exists(src_file):
        os.makedirs(target_dir, exist_ok=True)
        dest_file = os.path.join(target_dir, filename)
        print(f"Moving {filename} -> {domain}/presentation/screens/")
        shutil.move(src_file, dest_file)
        count += 1
    else:
        print(f"Skipping {filename} (not found)")

print(f"Migrated {count} screens.")
